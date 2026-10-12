-- Game read model for the app: one JSON shape for a game (booking + pitch +
-- players), matching the Flutter `Game.fromJson`. Plus the booker's tools
-- on the game page: who paid, open to others, and "Still coming?".

alter table public.game_players
  add column paid boolean not null default false,
  -- Answer to "Still coming?" (asked 10 hours before kick-off).
  add column confirmed boolean not null default true;

-- Share of known past games a player came to, 0–100 (100 with no history).
create function public.reliability_of(p_user uuid)
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select coalesce(
    round(100.0 * count(*) filter (where attended)
          / nullif(count(*) filter (where attended is not null), 0))::integer,
    100)
  from public.game_players where user_id = p_user;
$$;

-- Internal: the JSON for one game, as seen by the caller.
create function public.game_json(p_game uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', g.id,
    'starts_at', b.starts_at,
    'per_side', g.per_side,
    'status', b.status,
    'open', g.is_open,
    'waitlist', 0,
    'competitive', false,
    -- The booking QR token only for the booker.
    'code', case when b.booker_id = (select auth.uid())
                 then coalesce((select t.qr_token from public.booking_tickets t
                                where t.booking_id = b.id), '')
                 else '' end,
    'pitch', jsonb_build_object(
      'id', p.id, 'venue', v.name, 'venue_ar', coalesce(v.name_ar, v.name),
      'district', v.district, 'km', 0,
      'rating', coalesce((select round(avg(r.stars), 1) from public.pitch_ratings r
                          where r.pitch_id = p.id), 0),
      'reviews', (select count(*) from public.pitch_ratings r where r.pitch_id = p.id),
      'max_per_side', p.max_per_side, 'price_da', p.price_da,
      'features', to_jsonb(p.features), 'active', p.active),
    'players', coalesce((
      select jsonb_agg(jsonb_build_object(
        'name', pr.full_name, 'handle', pr.handle, 'position', gp.position,
        'team', lower(gp.team::text),
        'reliability', public.reliability_of(gp.user_id),
        'paid', gp.paid, 'confirmed', gp.confirmed, 'guest', false,
        'is_me', gp.user_id = (select auth.uid()),
        'is_booker', gp.user_id = b.booker_id,
        'attended', coalesce(gp.attended, false)
      ) order by gp.joined_at)
      from public.game_players gp join public.profiles pr on pr.id = gp.user_id
      where gp.game_id = g.id), '[]'::jsonb)
  )
  from public.games g
  join public.bookings b on b.id = g.booking_id
  join public.pitches p on p.id = b.pitch_id
  join public.venues v on v.id = p.venue_id
  where g.id = p_game;
$$;

-- My games: upcoming (live statuses, from 2 hours ago) or past.
create function public.my_games(p_past boolean default false)
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.game_json(g.id)
  from public.games g join public.bookings b on b.id = g.booking_id
  where (b.booker_id = (select auth.uid()) or public.in_game(g.id))
    and case when p_past
      then b.starts_at < now() - interval '2 hours'
           or b.status in ('completed', 'cancelled', 'no_show')
      else b.starts_at >= now() - interval '2 hours'
           and b.status in ('requested', 'confirmed', 'guaranteed')
    end
  order by case when p_past then -extract(epoch from b.starts_at)
                else extract(epoch from b.starts_at) end
  limit 50;
$$;

create function public.game_detail(p_game uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  bk uuid;
begin
  select booking_id into bk from public.games where id = p_game;
  if bk is null or not public.can_see_booking(bk) then
    raise exception 'game not found' using errcode = 'P0002';
  end if;
  return public.game_json(p_game);
end;
$$;

-- Open games that still need players, soonest first (not mine).
create function public.open_games(p_city text default null)
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.game_json(g.id)
  from public.games g
  join public.bookings b on b.id = g.booking_id
  join public.pitches p on p.id = b.pitch_id
  join public.venues v on v.id = p.venue_id
  where g.is_open and b.starts_at > now()
    and b.status in ('requested', 'confirmed', 'guaranteed')
    and (p_city is null or v.city_id = p_city)
    and not public.in_game(g.id)
    and (select count(*) from public.game_players gp where gp.game_id = g.id) < g.per_side * 2
  order by b.starts_at
  limit 30;
$$;

-- Booker tools on the game page.
create function public.set_player_paid(p_game uuid, p_handle text, p_paid boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.games g join public.bookings b on b.id = g.booking_id
                 where g.id = p_game and b.booker_id = (select auth.uid())) then
    raise exception 'booker only' using errcode = '42501';
  end if;
  update public.game_players gp set paid = p_paid
  from public.profiles pr
  where gp.game_id = p_game and gp.user_id = pr.id and pr.handle = p_handle;
end;
$$;

create function public.set_game_open(p_game uuid, p_open boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.games g set is_open = p_open
  from public.bookings b
  where g.id = p_game and b.id = g.booking_id and b.booker_id = (select auth.uid())
    and b.status in ('requested', 'confirmed', 'guaranteed');
  if not found then
    raise exception 'booker only' using errcode = '42501';
  end if;
end;
$$;

-- "Still coming?": yes keeps my spot; no frees it (the booker cancels instead).
create function public.confirm_coming(p_game uuid, p_coming boolean)
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
  else
    delete from public.game_players where game_id = p_game and user_id = me;
  end if;
end;
$$;

revoke all on function public.reliability_of(uuid), public.game_json(uuid)
  from public, anon, authenticated;
revoke all on function public.my_games(boolean), public.game_detail(uuid),
  public.open_games(text), public.set_player_paid(uuid, text, boolean),
  public.set_game_open(uuid, boolean), public.confirm_coming(uuid, boolean)
  from public, anon;
grant execute on function public.my_games(boolean), public.game_detail(uuid),
  public.open_games(text), public.set_player_paid(uuid, text, boolean),
  public.set_game_open(uuid, boolean), public.confirm_coming(uuid, boolean)
  to authenticated, service_role;
