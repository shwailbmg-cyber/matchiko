-- Matchiko core schema: reference data, profiles, venues, bookings, games,
-- matchmaking, social, ratings, rewards.
--
-- Security model (see docs/ARCHITECTURE.md § Security):
--   * RLS on every table. Clients get SELECT on what they may see and write
--     only a few self-owned columns. Every state change that matters
--     (booking status, verification, XP/coins) goes through SECURITY DEFINER
--     functions in the next migration.
--   * Supabase grants ALL on new public tables/functions to anon/authenticated
--     by default, so this file revokes everything and re-grants explicitly.
--   * Roles come from tables (venue_managers, referees), never from JWT
--     user_metadata.

create extension if not exists btree_gist with schema extensions;
create extension if not exists pgcrypto with schema extensions;

-- ── Enums ───────────────────────────────────────────────────────────────

create type public.position as enum ('gk', 'def', 'mid', 'fwd', 'ref');
create type public.game_format as enum ('5v5', '6v6', '8v8');
create type public.booking_status as enum
  ('requested', 'confirmed', 'guaranteed', 'completed', 'cancelled', 'no_show');
create type public.payment_method as enum ('cash', 'satim');
create type public.team_side as enum ('A', 'B');
create type public.match_mode as enum ('solo', 'friends', 'team');
create type public.time_window as enum ('morning', 'afternoon', 'evening', 'night');
create type public.request_status as enum
  ('searching', 'offered', 'matched', 'cancelled', 'expired');
create type public.offer_status as enum ('pending', 'accepted', 'declined', 'expired');
create type public.match_event_type as enum ('goal', 'yellow', 'red', 'mvp');
create type public.application_status as enum ('pending', 'approved', 'rejected');
create type public.friendship_status as enum ('pending', 'accepted');
create type public.reward_reason as enum
  ('show_up', 'rate_game', 'referee', 'win', 'goal', 'mvp', 'pay_online',
   'invite', 'verified', 'no_show', 'admin');

-- ── Reference data ──────────────────────────────────────────────────────

create table public.cities (
  id text primary key check (id ~ '^[a-z_]{2,30}$'),
  name_fr text not null,
  name_ar text not null
);

-- Reward amounts live in data so marketing can tune them without a release.
create table public.reward_rules (
  reason public.reward_reason primary key,
  xp integer not null,
  coins integer not null
);

-- ── People ──────────────────────────────────────────────────────────────

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  handle text not null unique check (handle ~ '^[a-z0-9_]{3,20}$'),
  full_name text not null default '' check (char_length(full_name) <= 60),
  avatar_url text check (avatar_url is null or avatar_url ~ '^https://'),
  city_id text references public.cities (id),
  positions public.position[] not null default '{mid}'
    check (cardinality(positions) between 1 and 4 and not ('ref' = any (positions))),
  lang text not null default 'fr' check (lang in ('en', 'fr', 'ar')),
  -- Server-owned below: never writable by clients (see grants).
  verified_at timestamptz,
  verified_by uuid references auth.users (id),
  xp integer not null default 0 check (xp >= 0),
  coins integer not null default 0 check (coins >= 0),
  no_show_count integer not null default 0,
  booking_ban_until timestamptz,
  created_at timestamptz not null default now()
);

comment on column public.profiles.verified_at is
  'Set by a stadium manager after checking the ID card in person (verify_player).';

-- New auth user → profile with a generated handle.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, handle)
  values (new.id, 'player_' || right(replace(new.id::text, '-', ''), 10));
  return new;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ── Venues and pitches ──────────────────────────────────────────────────

create table public.venues (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  name_ar text,
  city_id text not null references public.cities (id),
  district text not null default '',
  lat double precision check (lat between -90 and 90),
  lng double precision check (lng between -180 and 180),
  created_at timestamptz not null default now()
);

create table public.venue_managers (
  venue_id uuid not null references public.venues (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  primary key (venue_id, user_id)
);
create index venue_managers_user_idx on public.venue_managers (user_id);

create table public.pitches (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references public.venues (id) on delete cascade,
  name text not null default '',
  format public.game_format not null,
  price_da integer not null check (price_da > 0),
  features text[] not null default '{}'
    check (features <@ array['light', 'ball', 'shower', 'roof', 'ref']),
  active boolean not null default true
);
create index pitches_venue_idx on public.pitches (venue_id);

create table public.referees (
  user_id uuid primary key references auth.users (id) on delete cascade,
  approved_by uuid not null references auth.users (id),
  venue_id uuid not null references public.venues (id),
  approved_at timestamptz not null default now()
);

create table public.referee_applications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  venue_id uuid not null references public.venues (id) on delete cascade,
  status public.application_status not null default 'pending',
  created_at timestamptz not null default now(),
  unique (user_id, venue_id)
);

create table public.verification_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  venue_id uuid not null references public.venues (id) on delete cascade,
  created_at timestamptz not null default now(),
  unique (user_id, venue_id)
);
create index verification_requests_venue_idx on public.verification_requests (venue_id);

-- ── Bookings and games ──────────────────────────────────────────────────

create table public.bookings (
  id uuid primary key default gen_random_uuid(),
  pitch_id uuid not null references public.pitches (id),
  booker_id uuid not null references auth.users (id),
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  during tstzrange generated always as (tstzrange(starts_at, ends_at, '[)')) stored,
  status public.booking_status not null default 'requested',
  payment_method public.payment_method not null default 'cash',
  with_referee boolean not null default false,
  referee_id uuid references auth.users (id),
  total_da integer not null check (total_da > 0),
  confirmed_at timestamptz,
  guaranteed_at timestamptz,
  created_at timestamptz not null default now(),
  check (ends_at > starts_at),
  -- One active booking per pitch and time.
  exclude using gist (pitch_id with =, during with &&)
    where (status in ('requested', 'confirmed', 'guaranteed'))
);
create index bookings_booker_idx on public.bookings (booker_id);
create index bookings_referee_idx on public.bookings (referee_id);
create index bookings_pitch_time_idx on public.bookings (pitch_id, starts_at);

-- The QR secret is split out so only the booker can read it.
create table public.booking_tickets (
  booking_id uuid primary key references public.bookings (id) on delete cascade,
  qr_token text not null unique
    default encode(extensions.gen_random_bytes(16), 'hex')
);

create table public.games (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null unique references public.bookings (id) on delete cascade,
  format public.game_format not null,
  -- Open games show up in "Games missing players".
  is_open boolean not null default false,
  created_at timestamptz not null default now()
);
create index games_open_idx on public.games (is_open) where is_open;

create table public.game_players (
  game_id uuid not null references public.games (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  team public.team_side not null,
  position public.position not null,
  attended boolean,
  joined_at timestamptz not null default now(),
  primary key (game_id, user_id)
);
create index game_players_user_idx on public.game_players (user_id);

-- Written only by the SATIM Edge Function (service role).
create table public.payments (
  id uuid primary key default gen_random_uuid(),
  booking_id uuid not null references public.bookings (id),
  provider text not null default 'satim',
  provider_order_id text unique,
  amount_da integer not null check (amount_da > 0),
  status text not null default 'created' check (status in ('created', 'paid', 'failed')),
  raw jsonb,
  created_at timestamptz not null default now()
);
create index payments_booking_idx on public.payments (booking_id);

-- ── Matchmaking ─────────────────────────────────────────────────────────

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null check (char_length(name) between 2 and 40),
  captain_id uuid not null references auth.users (id),
  format public.game_format not null,
  created_at timestamptz not null default now()
);

create table public.team_members (
  team_id uuid not null references public.teams (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  primary key (team_id, user_id)
);
create index team_members_user_idx on public.team_members (user_id);

create table public.match_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  mode public.match_mode not null,
  team_id uuid references public.teams (id),
  friend_ids uuid[] not null default '{}' check (cardinality(friend_ids) <= 7),
  positions public.position[] not null check (cardinality(positions) between 1 and 4),
  format public.game_format not null,
  city_id text not null references public.cities (id),
  day date not null,
  windows public.time_window[] not null check (cardinality(windows) >= 1),
  radius_km integer not null default 5 check (radius_km between 1 and 50),
  want_referee boolean not null default false,
  status public.request_status not null default 'searching',
  created_at timestamptz not null default now(),
  check ((mode = 'team') = (team_id is not null))
);
create index match_requests_search_idx on public.match_requests (city_id, day, format)
  where status = 'searching';
create index match_requests_user_idx on public.match_requests (user_id);

create table public.match_offers (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.match_requests (id) on delete cascade,
  game_id uuid not null references public.games (id) on delete cascade,
  team public.team_side not null,
  position public.position not null,
  status public.offer_status not null default 'pending',
  expires_at timestamptz not null default now() + interval '30 seconds',
  created_at timestamptz not null default now()
);
create index match_offers_request_idx on public.match_offers (request_id);
create index match_offers_game_idx on public.match_offers (game_id);

-- ── Social ──────────────────────────────────────────────────────────────

create table public.friendships (
  requester_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  addressee_id uuid not null references auth.users (id) on delete cascade,
  status public.friendship_status not null default 'pending',
  created_at timestamptz not null default now(),
  primary key (requester_id, addressee_id),
  check (requester_id <> addressee_id)
);
create index friendships_addressee_idx on public.friendships (addressee_id);

create table public.notifications (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  kind text not null,
  payload jsonb not null default '{}',
  read_at timestamptz,
  created_at timestamptz not null default now()
);
create index notifications_user_idx on public.notifications (user_id, created_at desc);

-- ── After the game ──────────────────────────────────────────────────────

create table public.player_ratings (
  game_id uuid not null references public.games (id) on delete cascade,
  rater_id uuid not null references auth.users (id) on delete cascade,
  ratee_id uuid not null references auth.users (id) on delete cascade,
  stars smallint not null check (stars between 1 and 5),
  tags text[] not null default '{}'
    check (tags <@ array['fair_play', 'on_time', 'skilled', 'late']),
  created_at timestamptz not null default now(),
  primary key (game_id, rater_id, ratee_id),
  check (rater_id <> ratee_id)
);
create index player_ratings_ratee_idx on public.player_ratings (ratee_id);

create table public.pitch_ratings (
  game_id uuid not null references public.games (id) on delete cascade,
  rater_id uuid not null references auth.users (id) on delete cascade,
  pitch_id uuid not null references public.pitches (id) on delete cascade,
  stars smallint not null check (stars between 1 and 5),
  tags text[] not null default '{}'
    check (tags <@ array['new_turf', 'great_lights', 'clean', 'has_showers', 'old_ball', 'affordable']),
  created_at timestamptz not null default now(),
  primary key (game_id, rater_id)
);
create index pitch_ratings_pitch_idx on public.pitch_ratings (pitch_id);

create table public.match_events (
  id bigint generated always as identity primary key,
  game_id uuid not null references public.games (id) on delete cascade,
  referee_id uuid not null references auth.users (id),
  type public.match_event_type not null,
  team public.team_side not null,
  player_id uuid not null references auth.users (id),
  created_at timestamptz not null default now()
);
create index match_events_game_idx on public.match_events (game_id);

-- Append-only XP/coins history. profiles.xp/coins are its running totals.
create table public.wallet_ledger (
  id bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  reason public.reward_reason not null,
  ref_id uuid,
  xp_delta integer not null,
  coins_delta integer not null,
  created_at timestamptz not null default now(),
  -- Each reward is paid once per (user, reason, game/booking).
  unique nulls not distinct (user_id, reason, ref_id)
);

-- ── Helper functions used by policies ───────────────────────────────────

create function public.rank_of(xp integer)
returns text
language sql
immutable
set search_path = ''
as $$
  select case
    when xp >= 3500 then 'legend'
    when xp >= 2000 then 'elite'
    when xp >= 1000 then 'gold'
    when xp >= 500 then 'silver'
    else 'bronze'
  end;
$$;

create function public.is_venue_manager(p_venue uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.venue_managers
    where venue_id = p_venue and user_id = (select auth.uid())
  );
$$;

create function public.manages_booking(p_booking uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.bookings b
    join public.pitches p on p.id = b.pitch_id
    join public.venue_managers vm on vm.venue_id = p.venue_id
    where b.id = p_booking and vm.user_id = (select auth.uid())
  );
$$;

create function public.in_game(p_game uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.game_players
    where game_id = p_game and user_id = (select auth.uid())
  );
$$;

create function public.can_see_booking(p_booking uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1 from public.bookings b
    where b.id = p_booking
      and (b.booker_id = (select auth.uid()) or b.referee_id = (select auth.uid()))
  )
  or exists (
    select 1 from public.games g
    where g.booking_id = p_booking
      and (g.is_open or public.in_game(g.id))
  )
  or public.manages_booking(p_booking);
$$;

-- 'manager' when the user manages any venue, else 'player'. Decides which UI
-- the app shows; every manager action re-checks the specific venue.
create function public.my_role()
returns text
language sql
stable
security definer
set search_path = ''
as $$
  select case
    when exists (select 1 from public.venue_managers where user_id = (select auth.uid()))
      then 'manager'
    else 'player'
  end;
$$;

-- ── Row Level Security ──────────────────────────────────────────────────

alter table public.cities enable row level security;
alter table public.reward_rules enable row level security;
alter table public.profiles enable row level security;
alter table public.venues enable row level security;
alter table public.venue_managers enable row level security;
alter table public.pitches enable row level security;
alter table public.referees enable row level security;
alter table public.referee_applications enable row level security;
alter table public.verification_requests enable row level security;
alter table public.bookings enable row level security;
alter table public.booking_tickets enable row level security;
alter table public.games enable row level security;
alter table public.game_players enable row level security;
alter table public.payments enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.match_requests enable row level security;
alter table public.match_offers enable row level security;
alter table public.friendships enable row level security;
alter table public.notifications enable row level security;
alter table public.player_ratings enable row level security;
alter table public.pitch_ratings enable row level security;
alter table public.match_events enable row level security;
alter table public.wallet_ledger enable row level security;

-- Reference data: readable by signed-in users.
create policy "cities readable" on public.cities
  for select to authenticated using (true);
create policy "reward rules readable" on public.reward_rules
  for select to authenticated using (true);
create policy "venues readable" on public.venues
  for select to authenticated using (true);
create policy "pitches readable" on public.pitches
  for select to authenticated using (true);
create policy "referees readable" on public.referees
  for select to authenticated using (true);

-- Profiles: public columns readable by all signed-in users (column grants
-- below hide coins, bans and no-show counts); each user edits their own.
create policy "profiles readable" on public.profiles
  for select to authenticated using (true);
create policy "own profile editable" on public.profiles
  for update to authenticated
  using (id = (select auth.uid()))
  with check (id = (select auth.uid()));

create policy "own manager rows" on public.venue_managers
  for select to authenticated using (user_id = (select auth.uid()));

create policy "referee applications visible" on public.referee_applications
  for select to authenticated
  using (user_id = (select auth.uid()) or public.is_venue_manager(venue_id));
create policy "apply as referee" on public.referee_applications
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "verification requests visible" on public.verification_requests
  for select to authenticated
  using (user_id = (select auth.uid()) or public.is_venue_manager(venue_id));
create policy "request verification" on public.verification_requests
  for insert to authenticated
  with check (user_id = (select auth.uid()));

create policy "bookings visible" on public.bookings
  for select to authenticated using (public.can_see_booking(id));

create policy "own tickets" on public.booking_tickets
  for select to authenticated
  using (exists (
    select 1 from public.bookings b
    where b.id = booking_id and b.booker_id = (select auth.uid())
  ));

create policy "games visible" on public.games
  for select to authenticated using (public.can_see_booking(booking_id));
create policy "game players visible" on public.game_players
  for select to authenticated
  using (exists (
    select 1 from public.games g
    where g.id = game_id and public.can_see_booking(g.booking_id)
  ));

-- payments: no client policy (service role only).

create policy "teams readable" on public.teams
  for select to authenticated using (true);
create policy "create own team" on public.teams
  for insert to authenticated with check (captain_id = (select auth.uid()));
create policy "captain edits team" on public.teams
  for update to authenticated
  using (captain_id = (select auth.uid()))
  with check (captain_id = (select auth.uid()));

create policy "team members readable" on public.team_members
  for select to authenticated using (true);
create policy "captain adds members" on public.team_members
  for insert to authenticated
  with check (exists (
    select 1 from public.teams t
    where t.id = team_id and t.captain_id = (select auth.uid())
  ));
create policy "captain or self removes member" on public.team_members
  for delete to authenticated
  using (
    user_id = (select auth.uid())
    or exists (
      select 1 from public.teams t
      where t.id = team_id and t.captain_id = (select auth.uid())
    )
  );

create policy "own match requests" on public.match_requests
  for select to authenticated using (user_id = (select auth.uid()));
create policy "create own match request" on public.match_requests
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and status = 'searching'
    and (team_id is null or exists (
      select 1 from public.teams t
      where t.id = team_id and t.captain_id = (select auth.uid())
    ))
  );
create policy "cancel own match request" on public.match_requests
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()) and status = 'cancelled');

create policy "own match offers" on public.match_offers
  for select to authenticated
  using (exists (
    select 1 from public.match_requests r
    where r.id = request_id and r.user_id = (select auth.uid())
  ));

create policy "own friendships" on public.friendships
  for select to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));
create policy "send friend request" on public.friendships
  for insert to authenticated
  with check (requester_id = (select auth.uid()) and status = 'pending');
create policy "accept friend request" on public.friendships
  for update to authenticated
  using (addressee_id = (select auth.uid()))
  with check (addressee_id = (select auth.uid()));
create policy "remove friendship" on public.friendships
  for delete to authenticated
  using ((select auth.uid()) in (requester_id, addressee_id));

create policy "own notifications" on public.notifications
  for select to authenticated using (user_id = (select auth.uid()));
create policy "mark own notifications read" on public.notifications
  for update to authenticated
  using (user_id = (select auth.uid()))
  with check (user_id = (select auth.uid()));

-- Ratings are written through rate_game(). Players see ratings they gave
-- or got; pitch ratings are public (they feed the pitch score).
create policy "own player ratings" on public.player_ratings
  for select to authenticated
  using ((select auth.uid()) in (rater_id, ratee_id));
create policy "pitch ratings readable" on public.pitch_ratings
  for select to authenticated using (true);

create policy "match events visible" on public.match_events
  for select to authenticated
  using (exists (
    select 1 from public.games g
    where g.id = game_id and public.can_see_booking(g.booking_id)
  ));

create policy "own ledger" on public.wallet_ledger
  for select to authenticated using (user_id = (select auth.uid()));

-- ── Grants ──────────────────────────────────────────────────────────────
-- Start from nothing, then grant exactly what the policies above expect.

revoke all on all tables in schema public from anon, authenticated;
revoke all on all sequences in schema public from anon, authenticated;
revoke all on all functions in schema public from public, anon, authenticated;
grant all on all tables in schema public to service_role;
grant all on all sequences in schema public to service_role;
grant execute on all functions in schema public to service_role;

grant select on public.cities, public.reward_rules, public.venues, public.pitches,
  public.referees, public.venue_managers, public.bookings, public.booking_tickets,
  public.games, public.game_players, public.teams, public.team_members,
  public.match_requests, public.match_offers, public.friendships,
  public.notifications, public.player_ratings, public.pitch_ratings,
  public.match_events, public.wallet_ledger, public.referee_applications,
  public.verification_requests
  to authenticated;

-- Profiles: public columns only. Private ones come from get_my_profile().
grant select (id, handle, full_name, avatar_url, city_id, positions, verified_at,
  xp, created_at) on public.profiles to authenticated;
grant update (handle, full_name, avatar_url, city_id, positions, lang)
  on public.profiles to authenticated;

grant insert (venue_id, user_id) on public.referee_applications to authenticated;
grant insert (venue_id, user_id) on public.verification_requests to authenticated;
grant insert (name, captain_id, format) on public.teams to authenticated;
grant update (name, format) on public.teams to authenticated;
grant insert (team_id, user_id) on public.team_members to authenticated;
grant delete on public.team_members to authenticated;
grant insert (mode, team_id, friend_ids, positions, format, city_id, day, windows,
  radius_km, want_referee) on public.match_requests to authenticated;
grant update (status) on public.match_requests to authenticated;
grant insert (addressee_id) on public.friendships to authenticated;
grant update (status) on public.friendships to authenticated;
grant delete on public.friendships to authenticated;
grant update (read_at) on public.notifications to authenticated;

grant execute on function public.rank_of(integer), public.is_venue_manager(uuid),
  public.manages_booking(uuid), public.in_game(uuid), public.can_see_booking(uuid),
  public.my_role()
  to authenticated;

-- Live updates the app subscribes to (RLS still applies).
alter publication supabase_realtime add table
  public.match_offers, public.bookings, public.notifications;
