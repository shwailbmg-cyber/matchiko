-- Fixes from the branch security review.

-- 1. Leaving a game is only possible before kick-off. Otherwise a player
-- could skip a game, then delete their row to dodge the no-show penalty,
-- wipe a past no-show from their reliability, or avoid a report.
create or replace function public.confirm_coming(p_game uuid, p_coming boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if not public.in_game(p_game) then
    raise exception 'not in this game' using errcode = '42501';
  end if;
  if p_coming then
    update public.game_players set confirmed = true where game_id = p_game and user_id = me;
  elsif exists (select 1 from public.games g join public.bookings b on b.id = g.booking_id
                where g.id = p_game and b.booker_id = me) then
    raise exception 'the booker cancels the booking instead' using errcode = '22023';
  elsif not exists (select 1 from public.games g join public.bookings b on b.id = g.booking_id
                    where g.id = p_game and b.starts_at > now()
                      and b.status in ('requested', 'confirmed', 'guaranteed')) then
    raise exception 'game already started' using errcode = '22023';
  else
    delete from public.game_players where game_id = p_game and user_id = me;
  end if;
end;
$$;

-- 2. One friend-request notification per pair and day (no push spam by
-- deleting and re-sending a request).
create or replace function public.notify_friend_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'pending' then
    insert into public.notifications (user_id, kind, payload)
    select new.addressee_id, 'friend_request',
           jsonb_build_object('handle', p.handle, 'name', p.full_name)
    from public.profiles p
    where p.id = new.requester_id
      and not exists (select 1 from public.notifications n
                      where n.user_id = new.addressee_id and n.kind = 'friend_request'
                        and n.payload ->> 'handle' = p.handle
                        and n.created_at > now() - interval '1 day');
  end if;
  return null;
end;
$$;

-- 3. "Spot open" once per friend and game (no spam by closing and
-- reopening the game).
create or replace function public.notify_game_opened()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.is_open and not old.is_open then
    insert into public.notifications (user_id, kind, payload)
    select pr.id, 'spot_open',
           jsonb_build_object('game_id', new.id, 'pitch', v.name,
                              'time', public.hhmm(b.starts_at))
    from public.bookings b
    join public.pitches p on p.id = b.pitch_id
    join public.venues v on v.id = p.venue_id
    join public.friendships f on f.status = 'accepted'
      and b.booker_id in (f.requester_id, f.addressee_id)
    join public.profiles pr on pr.id = case when f.requester_id = b.booker_id
                                            then f.addressee_id else f.requester_id end
    where b.id = new.booking_id and b.starts_at > now()
      and pr.notify_nearby
      and not exists (select 1 from public.game_players gp
                      where gp.game_id = new.id and gp.user_id = pr.id)
      and not exists (select 1 from public.blocked_users bu
                      where (bu.blocker_id = pr.id and bu.blocked_id = b.booker_id)
                         or (bu.blocked_id = pr.id and bu.blocker_id = b.booker_id))
      and not exists (select 1 from public.notifications n
                      where n.user_id = pr.id and n.kind = 'spot_open'
                        and n.payload ->> 'game_id' = new.id::text);
  end if;
  return null;
end;
$$;

-- 4. At most 5 devices per user (each token costs one FCM call per push).
create or replace function public.register_push_token(p_token text, p_platform text)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.push_tokens (token, user_id, platform)
  values (p_token, (select auth.uid()), p_platform)
  on conflict (token) do update
    set user_id = excluded.user_id, platform = excluded.platform, updated_at = now();
  delete from public.push_tokens
  where user_id = (select auth.uid())
    and token not in (select t.token from public.push_tokens t
                      where t.user_id = (select auth.uid())
                      order by t.updated_at desc limit 5);
$$;

-- 5. Lock the venue while removing a manager, so two managers removing
-- each other at once can't leave it with none.
create or replace function public.remove_venue_manager(p_venue uuid, p_handle text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_venue_manager(p_venue) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  perform 1 from public.venues where id = p_venue for update;
  if (select count(*) from public.venue_managers where venue_id = p_venue) <= 1 then
    raise exception 'a venue needs at least one manager' using errcode = '22023';
  end if;
  delete from public.venue_managers vm
  using public.profiles p
  where vm.venue_id = p_venue and vm.user_id = p.id and p.handle = lower(p_handle);
end;
$$;

-- 6. "Who sees my games": people outside the game (open games list,
-- matchmaking) see a private player as a nameless guest. Players of the
-- game, its referee and the venue's managers still see everyone.
alter function public.game_json(uuid) rename to game_json_full;

create function public.game_json(p_game uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when public.in_game(g.id) or public.manages_booking(b.id)
         or (select auth.uid()) in (b.booker_id, b.referee_id)
      then j
    else jsonb_set(j, '{players}', coalesce((
      select jsonb_agg(case
        when pr.games_visibility = 'everyone'
          or (pr.games_visibility = 'friends' and exists (
                select 1 from public.friendships f where f.status = 'accepted'
                  and ((f.requester_id = pr.id and f.addressee_id = (select auth.uid()))
                    or (f.addressee_id = pr.id and f.requester_id = (select auth.uid())))))
          then x
        else x || jsonb_build_object('name', '', 'handle', '', 'guest', true)
      end order by ord)
      from jsonb_array_elements(j -> 'players') with ordinality as e(x, ord)
      left join public.profiles pr on pr.handle = x ->> 'handle'), '[]'::jsonb))
  end
  from public.games g
  join public.bookings b on b.id = g.booking_id,
  lateral (select public.game_json_full(g.id) as j) full_json
  where g.id = p_game;
$$;

revoke all on function public.game_json_full(uuid), public.game_json(uuid)
  from public, anon, authenticated;
