-- The game loop's server-side rules: booking, manager confirmation, QR scan,
-- no-shows, completion and rewards, verification, ratings, referee reports.
--
-- Every function here is SECURITY DEFINER with an empty search_path, checks
-- who is calling, and is granted to `authenticated` only. Internal helpers
-- (award, apply_no_show) are not granted to clients at all.

-- ── Booking state machine (defense in depth, also blocks service-role bugs) ─

create function public.bookings_status_guard()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  if new.status is distinct from old.status and not (
    (old.status = 'requested' and new.status in ('confirmed', 'guaranteed', 'cancelled'))
    or (old.status = 'confirmed' and new.status in ('guaranteed', 'cancelled', 'no_show'))
    or (old.status = 'guaranteed' and new.status in ('completed', 'no_show'))
  ) then
    raise exception 'illegal booking transition % -> %', old.status, new.status
      using errcode = 'check_violation';
  end if;
  if new.status = 'confirmed' and old.status <> 'confirmed' then
    new.confirmed_at := now();
  end if;
  if new.status = 'guaranteed' and old.status <> 'guaranteed' then
    new.guaranteed_at := now();
  end if;
  return new;
end;
$$;

create trigger bookings_status_guard
  before update of status on public.bookings
  for each row execute function public.bookings_status_guard();

-- ── Rewards (internal) ──────────────────────────────────────────────────

-- Pays the reward for `reason` once per (user, reason, ref). Returns false if
-- it was already paid. Amounts come from reward_rules.
create function public.award(p_user uuid, p_reason public.reward_reason, p_ref uuid)
returns boolean
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.reward_rules;
begin
  select * into r from public.reward_rules where reason = p_reason;
  if not found then
    raise exception 'no reward rule for %', p_reason;
  end if;
  insert into public.wallet_ledger (user_id, reason, ref_id, xp_delta, coins_delta)
  values (p_user, p_reason, p_ref, r.xp, r.coins)
  on conflict (user_id, reason, ref_id) do nothing;
  if not found then
    return false;
  end if;
  update public.profiles
  set xp = greatest(0, xp + r.xp), coins = greatest(0, coins + r.coins)
  where id = p_user;
  return true;
end;
$$;

-- −XP/−coins, and a 7-day booking ban on the 2nd no-show.
create function public.apply_no_show(p_user uuid, p_ref uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if public.award(p_user, 'no_show', p_ref) then
    update public.profiles
    set no_show_count = no_show_count + 1,
        booking_ban_until = case
          when no_show_count + 1 >= 2 then now() + interval '7 days'
          else booking_ban_until
        end
    where id = p_user;
    update public.profiles set no_show_count = 0
    where id = p_user and no_show_count >= 2;
  end if;
end;
$$;

-- ── Player: profile ─────────────────────────────────────────────────────

create function public.get_my_profile()
returns table (
  id uuid, handle text, full_name text, avatar_url text, city_id text,
  positions public.position[], lang text, verified_at timestamptz, xp integer,
  rank text, coins integer, no_show_count integer, booking_ban_until timestamptz,
  is_referee boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.handle, p.full_name, p.avatar_url, p.city_id, p.positions, p.lang,
    p.verified_at, p.xp, public.rank_of(p.xp), p.coins, p.no_show_count,
    p.booking_ban_until,
    exists (select 1 from public.referees r where r.user_id = p.id)
  from public.profiles p
  where p.id = (select auth.uid());
$$;

-- ── Player: book a pitch ────────────────────────────────────────────────

-- Requests a 1-hour slot. Verified players only, no active ban. The price is
-- computed here, never sent by the app. The booker joins team A.
create function public.request_booking(
  p_pitch uuid,
  p_starts_at timestamptz,
  p_with_referee boolean default false,
  p_payment public.payment_method default 'cash',
  p_position public.position default 'mid',
  p_open boolean default false
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  prof public.profiles;
  pitch public.pitches;
  booking_id uuid;
  game_id uuid;
begin
  if me is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  select * into prof from public.profiles where id = me;
  if prof.verified_at is null then
    raise exception 'verification required' using errcode = '42501';
  end if;
  if prof.booking_ban_until is not null and prof.booking_ban_until > now() then
    raise exception 'booking ban until %', prof.booking_ban_until using errcode = '42501';
  end if;
  select * into pitch from public.pitches where id = p_pitch and active;
  if not found then
    raise exception 'unknown pitch' using errcode = 'P0002';
  end if;
  if p_starts_at <= now() or p_starts_at > now() + interval '30 days'
     or date_trunc('hour', p_starts_at) <> p_starts_at then
    raise exception 'invalid start time' using errcode = '22023';
  end if;
  if p_position = 'ref' then
    raise exception 'invalid position' using errcode = '22023';
  end if;
  if (select count(*) from public.bookings
      where booker_id = me and status = 'requested') >= 3 then
    raise exception 'too many pending requests' using errcode = '42501';
  end if;

  insert into public.bookings
    (pitch_id, booker_id, starts_at, ends_at, payment_method, with_referee, total_da)
  values
    (p_pitch, me, p_starts_at, p_starts_at + interval '1 hour', p_payment,
     p_with_referee, pitch.price_da + case when p_with_referee then 200 else 0 end)
  returning id into booking_id;

  insert into public.booking_tickets (booking_id) values (booking_id);
  insert into public.games (booking_id, format, is_open)
  values (booking_id, pitch.format, p_open)
  returning id into game_id;
  insert into public.game_players (game_id, user_id, team, position)
  values (game_id, me, 'A', p_position);
  return booking_id;
end;
$$;

create function public.cancel_booking(p_booking uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.bookings set status = 'cancelled'
  where id = p_booking
    and (booker_id = (select auth.uid()) or public.manages_booking(id))
    and status in ('requested', 'confirmed');
  if not found then
    raise exception 'booking not found or not cancellable' using errcode = 'P0002';
  end if;
end;
$$;

-- Unverified players may join games (only booking needs verification).
create function public.join_open_game(p_game uuid, p_position public.position)
returns public.team_side
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  g public.games;
  b public.bookings;
  per_team integer;
  a_count integer;
  b_count integer;
  side public.team_side;
begin
  select * into g from public.games where id = p_game for update;
  if not found or not g.is_open then
    raise exception 'game not open' using errcode = 'P0002';
  end if;
  select * into b from public.bookings where id = g.booking_id;
  if b.status not in ('requested', 'confirmed', 'guaranteed') or b.starts_at <= now() then
    raise exception 'game not joinable' using errcode = '22023';
  end if;
  if exists (select 1 from public.profiles
             where id = me and booking_ban_until > now()) then
    raise exception 'banned' using errcode = '42501';
  end if;
  if p_position = 'ref' then
    raise exception 'invalid position' using errcode = '22023';
  end if;
  per_team := left(g.format::text, 1)::integer;
  select count(*) filter (where team = 'A'), count(*) filter (where team = 'B')
    into a_count, b_count
  from public.game_players where game_id = p_game;
  if a_count + b_count >= per_team * 2 then
    raise exception 'game full' using errcode = '22023';
  end if;
  side := case when a_count <= b_count then 'A' else 'B' end;
  insert into public.game_players (game_id, user_id, team, position)
  values (p_game, me, side, p_position);
  return side;
end;
$$;

-- ── Manager: confirm, scan, no-show, complete ───────────────────────────

create function public.confirm_booking(p_booking uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.manages_booking(p_booking) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  update public.bookings set status = 'confirmed'
  where id = p_booking and status = 'requested';
  if not found then
    raise exception 'booking is not waiting for confirmation' using errcode = '22023';
  end if;
end;
$$;

-- Manager scans the player's QR after receiving the cash → Guaranteed.
-- Only works for bookings at a venue the caller manages.
create function public.scan_booking_qr(p_token text)
returns table (booking_id uuid, booker_handle text, starts_at timestamptz, total_da integer)
language plpgsql
security definer
set search_path = ''
as $$
declare
  b public.bookings;
begin
  select bk.* into b
  from public.booking_tickets t
  join public.bookings bk on bk.id = t.booking_id
  where t.qr_token = p_token;
  if not found or not public.manages_booking(b.id) then
    raise exception 'unknown ticket' using errcode = 'P0002';
  end if;
  if b.status not in ('requested', 'confirmed') then
    raise exception 'booking already %', b.status using errcode = '22023';
  end if;
  update public.bookings set status = 'guaranteed' where id = b.id;
  return query
    select b.id, p.handle, b.starts_at, b.total_da
    from public.profiles p where p.id = b.booker_id;
end;
$$;

create function public.mark_no_show(p_booking uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  b public.bookings;
begin
  if not public.manages_booking(p_booking) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  update public.bookings set status = 'no_show'
  where id = p_booking and status in ('confirmed', 'guaranteed')
  returning * into b;
  if not found then
    raise exception 'booking cannot be marked no-show' using errcode = '22023';
  end if;
  perform public.apply_no_show(b.booker_id, b.id);
end;
$$;

-- After the game: everyone present gets show_up, absent players get the
-- no-show penalty.
create function public.complete_booking(p_booking uuid, p_absent uuid[] default '{}')
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  g public.games;
  gp record;
begin
  if not public.manages_booking(p_booking) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  update public.bookings set status = 'completed'
  where id = p_booking and status = 'guaranteed' and starts_at <= now();
  if not found then
    raise exception 'only started, guaranteed bookings can be completed' using errcode = '22023';
  end if;
  select * into g from public.games where booking_id = p_booking;
  for gp in select user_id from public.game_players where game_id = g.id loop
    if gp.user_id = any (p_absent) then
      update public.game_players set attended = false
      where game_id = g.id and user_id = gp.user_id;
      perform public.apply_no_show(gp.user_id, g.id);
    else
      update public.game_players set attended = true
      where game_id = g.id and user_id = gp.user_id;
      perform public.award(gp.user_id, 'show_up', g.id);
    end if;
  end loop;
end;
$$;

-- ── Manager: verify players, approve referees ───────────────────────────

-- Called after checking the ID card in person (name + photo + age 16+).
create function public.verify_player(p_handle text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  target uuid;
begin
  if not exists (select 1 from public.venue_managers where user_id = me) then
    raise exception 'managers only' using errcode = '42501';
  end if;
  select id into target from public.profiles where handle = lower(p_handle);
  if not found then
    raise exception 'unknown player' using errcode = 'P0002';
  end if;
  if target = me then
    raise exception 'cannot verify yourself' using errcode = '42501';
  end if;
  update public.profiles set verified_at = now(), verified_by = me
  where id = target and verified_at is null;
  if found then
    perform public.award(target, 'verified', null);
  end if;
  delete from public.verification_requests where user_id = target;
  return target;
end;
$$;

create function public.approve_referee(p_application uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  a public.referee_applications;
begin
  select * into a from public.referee_applications
  where id = p_application and status = 'pending';
  if not found or not public.is_venue_manager(a.venue_id) then
    raise exception 'application not found' using errcode = 'P0002';
  end if;
  if not exists (select 1 from public.profiles
                 where id = a.user_id and verified_at is not null) then
    raise exception 'referees must be verified first' using errcode = '22023';
  end if;
  update public.referee_applications set status = 'approved' where id = a.id;
  insert into public.referees (user_id, approved_by, venue_id)
  values (a.user_id, (select auth.uid()), a.venue_id)
  on conflict (user_id) do nothing;
end;
$$;

create function public.reject_referee(p_application uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.referee_applications set status = 'rejected'
  where id = p_application and status = 'pending'
    and public.is_venue_manager(venue_id);
  if not found then
    raise exception 'application not found' using errcode = 'P0002';
  end if;
end;
$$;

-- ── After the game: ratings and referee report ──────────────────────────

-- p_players: [{"user_id": "...", "stars": 4, "tags": ["fair_play"]}, ...]
create function public.rate_game(
  p_game uuid,
  p_pitch_stars smallint,
  p_pitch_tags text[] default '{}',
  p_players jsonb default '[]'
)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  b public.bookings;
  pr jsonb;
begin
  if not public.in_game(p_game) then
    raise exception 'not in this game' using errcode = '42501';
  end if;
  select bk.* into b from public.games g join public.bookings bk on bk.id = g.booking_id
  where g.id = p_game;
  if b.status <> 'completed' or b.ends_at < now() - interval '7 days' then
    raise exception 'game not open for rating' using errcode = '22023';
  end if;
  if jsonb_typeof(p_players) <> 'array' or jsonb_array_length(p_players) > 20 then
    raise exception 'invalid ratings' using errcode = '22023';
  end if;

  insert into public.pitch_ratings (game_id, rater_id, pitch_id, stars, tags)
  values (p_game, me, b.pitch_id, p_pitch_stars, p_pitch_tags)
  on conflict (game_id, rater_id) do nothing;

  for pr in select * from jsonb_array_elements(p_players) loop
    insert into public.player_ratings (game_id, rater_id, ratee_id, stars, tags)
    select p_game, me, gp.user_id, (pr ->> 'stars')::smallint,
      coalesce(array(select jsonb_array_elements_text(pr -> 'tags')), '{}')
    from public.game_players gp
    where gp.game_id = p_game and gp.user_id = (pr ->> 'user_id')::uuid
      and gp.user_id <> me
    on conflict do nothing;
  end loop;

  perform public.award(me, 'rate_game', p_game);
end;
$$;

-- p_events: [{"type": "goal", "team": "A", "player_id": "..."}, ...]
-- The booking's referee submits once; rewards: referee, win, goal, mvp.
create function public.submit_match_report(p_game uuid, p_events jsonb)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  b public.bookings;
  e jsonb;
  goals_a integer;
  goals_b integer;
  winner public.team_side;
  gp record;
begin
  select bk.* into b from public.games g join public.bookings bk on bk.id = g.booking_id
  where g.id = p_game;
  if not found or b.referee_id is distinct from me then
    raise exception 'not the referee of this game' using errcode = '42501';
  end if;
  if b.status not in ('guaranteed', 'completed') or b.starts_at > now() then
    raise exception 'game has not started' using errcode = '22023';
  end if;
  if exists (select 1 from public.match_events where game_id = p_game) then
    raise exception 'report already submitted' using errcode = '22023';
  end if;
  if jsonb_typeof(p_events) <> 'array' or jsonb_array_length(p_events) > 100 then
    raise exception 'invalid events' using errcode = '22023';
  end if;

  for e in select * from jsonb_array_elements(p_events) loop
    insert into public.match_events (game_id, referee_id, type, team, player_id)
    select p_game, me, (e ->> 'type')::public.match_event_type,
      (e ->> 'team')::public.team_side, gp.user_id
    from public.game_players gp
    where gp.game_id = p_game and gp.user_id = (e ->> 'player_id')::uuid
      and gp.team = (e ->> 'team')::public.team_side;
    if not found then
      raise exception 'event player not in that team' using errcode = '22023';
    end if;
  end loop;
  if (select count(*) from public.match_events
      where game_id = p_game and type = 'mvp') > 1 then
    raise exception 'only one MVP' using errcode = '22023';
  end if;

  perform public.award(me, 'referee', p_game);

  select count(*) filter (where team = 'A' and type = 'goal'),
         count(*) filter (where team = 'B' and type = 'goal')
    into goals_a, goals_b
  from public.match_events where game_id = p_game;
  winner := case when goals_a > goals_b then 'A'
                 when goals_b > goals_a then 'B' end;

  for gp in select user_id, team from public.game_players where game_id = p_game loop
    if winner is not null and gp.team = winner then
      perform public.award(gp.user_id, 'win', p_game);
    end if;
    if exists (select 1 from public.match_events where game_id = p_game
               and player_id = gp.user_id and type = 'goal') then
      perform public.award(gp.user_id, 'goal', p_game);
    end if;
    if exists (select 1 from public.match_events where game_id = p_game
               and player_id = gp.user_id and type = 'mvp') then
      perform public.award(gp.user_id, 'mvp', p_game);
    end if;
  end loop;
end;
$$;

-- ── Grants ──────────────────────────────────────────────────────────────

revoke all on all functions in schema public from public, anon, authenticated;
grant execute on all functions in schema public to service_role;

grant execute on function
  public.rank_of(integer),
  public.is_venue_manager(uuid),
  public.manages_booking(uuid),
  public.in_game(uuid),
  public.can_see_booking(uuid),
  public.my_role(),
  public.get_my_profile(),
  public.request_booking(uuid, timestamptz, boolean, public.payment_method, public.position, boolean),
  public.cancel_booking(uuid),
  public.join_open_game(uuid, public.position),
  public.confirm_booking(uuid),
  public.scan_booking_qr(text),
  public.mark_no_show(uuid),
  public.complete_booking(uuid, uuid[]),
  public.verify_player(text),
  public.approve_referee(uuid),
  public.reject_referee(uuid),
  public.rate_game(uuid, smallint, text[], jsonb),
  public.submit_match_report(uuid, jsonb)
  to authenticated;
