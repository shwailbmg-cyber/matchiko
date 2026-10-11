-- 1) Flexible game sizes. A pitch has a maximum size (7 for a 7-a-side pitch,
--    11 for a full pitch); each game picks its players per side, from 3 up to
--    the pitch maximum (5v5, 6v6, 7v7, 8v8, 11v11…). Replaces the fixed
--    '5v5' / '6v6' / '8v8' enum.
-- 2) Booker cancellations cost XP/coins (reward rule 'cancellation').

-- ── 1. Formats ──────────────────────────────────────────────────────────

alter table public.pitches add column max_per_side smallint;
update public.pitches set max_per_side = left(format::text, 1)::smallint;
alter table public.pitches
  alter column max_per_side set not null,
  add constraint pitches_max_per_side_check check (max_per_side between 3 and 11),
  drop column format;

alter table public.games add column per_side smallint;
update public.games set per_side = left(format::text, 1)::smallint;
alter table public.games
  alter column per_side set not null,
  add constraint games_per_side_check check (per_side between 3 and 11),
  drop column format;

alter table public.teams add column per_side smallint;
update public.teams set per_side = left(format::text, 1)::smallint;
alter table public.teams
  alter column per_side set not null,
  add constraint teams_per_side_check check (per_side between 3 and 11),
  drop column format;

drop index public.match_requests_search_idx;
alter table public.match_requests add column per_side smallint;
update public.match_requests set per_side = left(format::text, 1)::smallint;
alter table public.match_requests
  alter column per_side set not null,
  add constraint match_requests_per_side_check check (per_side between 3 and 11),
  drop column format;
create index match_requests_search_idx on public.match_requests (city_id, day, per_side)
  where status = 'searching';

drop type public.game_format;

grant insert (name, captain_id, per_side) on public.teams to authenticated;
grant update (name, per_side) on public.teams to authenticated;
grant insert (per_side) on public.match_requests to authenticated;

-- request_booking gains p_per_side (default: the pitch maximum).
drop function public.request_booking(uuid, timestamptz, boolean, public.payment_method, public.position, boolean);
create function public.request_booking(
  p_pitch uuid,
  p_starts_at timestamptz,
  p_with_referee boolean default false,
  p_payment public.payment_method default 'cash',
  p_position public.position default 'mid',
  p_open boolean default false,
  p_per_side smallint default null
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
  size smallint;
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
  size := coalesce(p_per_side, pitch.max_per_side);
  if size < 3 or size > pitch.max_per_side then
    raise exception 'pitch fits 3 to % players per side', pitch.max_per_side
      using errcode = '22023';
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
  insert into public.games (booking_id, per_side, is_open)
  values (booking_id, size, p_open)
  returning id into game_id;
  insert into public.game_players (game_id, user_id, team, position)
  values (game_id, me, 'A', p_position);
  return booking_id;
end;
$$;

-- The booker can resize the game before it starts (e.g. 7v7 → 6v6 when
-- people drop out), within the pitch maximum and the players already in.
create function public.set_game_size(p_game uuid, p_per_side smallint)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  b public.bookings;
  max_size smallint;
  players integer;
begin
  select bk.* into b from public.games g join public.bookings bk on bk.id = g.booking_id
  where g.id = p_game;
  if not found or b.booker_id is distinct from (select auth.uid()) then
    raise exception 'only the booker can resize the game' using errcode = '42501';
  end if;
  if b.status not in ('requested', 'confirmed', 'guaranteed') or b.starts_at <= now() then
    raise exception 'game can no longer be changed' using errcode = '22023';
  end if;
  select p.max_per_side into max_size from public.pitches p where p.id = b.pitch_id;
  select count(*) into players from public.game_players where game_id = p_game;
  if p_per_side < 3 or p_per_side > max_size or players > p_per_side * 2 then
    raise exception 'size must be 3 to % per side and fit the % players already in',
      max_size, players using errcode = '22023';
  end if;
  update public.games set per_side = p_per_side where id = p_game;
end;
$$;

create or replace function public.join_open_game(p_game uuid, p_position public.position)
returns public.team_side
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  g public.games;
  b public.bookings;
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
  select count(*) filter (where team = 'A'), count(*) filter (where team = 'B')
    into a_count, b_count
  from public.game_players where game_id = p_game;
  if a_count + b_count >= g.per_side * 2 then
    raise exception 'game full' using errcode = '22023';
  end if;
  side := case when a_count <= b_count then 'A' else 'B' end;
  insert into public.game_players (game_id, user_id, team, position)
  values (p_game, me, side, p_position);
  return side;
end;
$$;

-- ── 2. Cancellations ────────────────────────────────────────────────────

insert into public.reward_rules (reason, xp, coins) values ('cancellation', -20, -10)
on conflict (reason) do update set xp = excluded.xp, coins = excluded.coins;

-- A booker cancelling pays the cancellation penalty; a manager cancelling
-- (e.g. pitch problem) doesn't penalise anyone.
create or replace function public.cancel_booking(p_booking uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  b public.bookings;
begin
  update public.bookings set status = 'cancelled'
  where id = p_booking
    and (booker_id = me or public.manages_booking(id))
    and status in ('requested', 'confirmed')
  returning * into b;
  if not found then
    raise exception 'booking not found or not cancellable' using errcode = 'P0002';
  end if;
  if b.booker_id = me then
    perform public.award(me, 'cancellation', b.id);
  end if;
end;
$$;

revoke all on function public.request_booking(uuid, timestamptz, boolean, public.payment_method, public.position, boolean, smallint),
  public.set_game_size(uuid, smallint), public.join_open_game(uuid, public.position),
  public.cancel_booking(uuid)
  from public, anon;
grant execute on function public.request_booking(uuid, timestamptz, boolean, public.payment_method, public.position, boolean, smallint),
  public.set_game_size(uuid, smallint), public.join_open_game(uuid, public.position),
  public.cancel_booking(uuid)
  to authenticated, service_role;

alter table public.profiles alter column lang set default 'en';
