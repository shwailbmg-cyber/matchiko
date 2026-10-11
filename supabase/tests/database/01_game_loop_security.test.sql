-- Security and game-loop rules. Run: `supabase test db` (or tests/local/run.sh).
-- Users: a1 = verified player (seed), a2 = manager of venue a001 (seed),
--        a3 = unverified player, a4 = manager of another venue (created here).
begin;
set search_path = public, extensions;
select plan(31);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a4', '213555000004');
insert into public.venues (id, name, city_id) values
  ('00000000-0000-0000-0000-00000000a009', 'Other venue', 'oran');
insert into public.venue_managers (venue_id, user_id) values
  ('00000000-0000-0000-0000-00000000a009', '00000000-0000-0000-0000-0000000000a4');

create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;

-- ── Structure ───────────────────────────────────────────────────────────

select is(
  (select count(*)::int from pg_tables where schemaname = 'public' and not rowsecurity),
  0, 'RLS is enabled on every public table');

select is(
  (select count(*)::int from information_schema.role_table_grants
   where table_schema = 'public' and grantee = 'anon'),
  0, 'anon has no table privileges');

select ok(
  not has_function_privilege('authenticated', 'public.award(uuid, public.reward_reason, uuid)', 'execute'),
  'clients cannot call award()');

select ok(
  not has_function_privilege('anon', 'public.request_booking(uuid, timestamptz, boolean, public.payment_method, public.position, boolean, smallint)', 'execute'),
  'anon cannot call RPCs');

-- ── Player a1 ───────────────────────────────────────────────────────────

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;

select is(public.my_role(), 'player', 'a1 is a player');

select throws_ok(
  $$ update public.profiles set coins = 99999 where id = auth.uid() $$,
  '42501', null, 'player cannot change own coins');
select throws_ok(
  $$ update public.profiles set verified_at = now() where id = auth.uid() $$,
  '42501', null, 'player cannot self-verify');
select throws_ok(
  $$ select coins from public.profiles where id = auth.uid() $$,
  '42501', null, 'coins column is not readable directly');

select lives_ok(
  $$ update public.profiles set full_name = 'Amine B.' where id = auth.uid() $$,
  'player can edit own name');
update public.profiles set full_name = 'Hacked' where id = '00000000-0000-0000-0000-0000000000a2';
select is(
  (select full_name from public.profiles where id = '00000000-0000-0000-0000-0000000000a2'),
  'Manager El Harrach', 'player cannot edit someone else''s profile');

select is((select coins from public.get_my_profile()), 340, 'get_my_profile returns private fields');

select throws_ok(
  $$ insert into public.bookings (pitch_id, booker_id, starts_at, ends_at, total_da)
     values ('00000000-0000-0000-0000-00000000b001', auth.uid(), now() + interval '1 day',
             now() + interval '1 day 1 hour', 1) $$,
  '42501', null, 'player cannot insert bookings directly');

insert into ctx values ('b1', public.request_booking(
  '00000000-0000-0000-0000-00000000b001',
  date_trunc('hour', now()) + interval '2 days', true)::text);
select is(
  (select total_da from public.bookings where id = (select v from ctx where k = 'b1')::uuid),
  2700, 'price is computed server-side (2500 + 200 referee)');
select is(
  (select status::text from public.bookings where id = (select v from ctx where k = 'b1')::uuid),
  'requested', 'new booking is requested');

select throws_ok(
  $$ select public.request_booking('00000000-0000-0000-0000-00000000b001',
       date_trunc('hour', now()) + interval '2 days') $$,
  '23P01', null, 'same pitch and hour cannot be booked twice');

select throws_ok(
  $$ select public.confirm_booking((select v from ctx where k = 'b1')::uuid) $$,
  '42501', null, 'player cannot confirm a booking');

insert into ctx select 'qr', qr_token from public.booking_tickets
  where booking_id = (select v from ctx where k = 'b1')::uuid;
select is((select count(*)::int from ctx where k = 'qr'), 1, 'booker can read own QR ticket');

-- ── Unverified player a3 ────────────────────────────────────────────────

reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;

select throws_ok(
  $$ select public.request_booking('00000000-0000-0000-0000-00000000b002',
       date_trunc('hour', now()) + interval '3 days') $$,
  '42501', 'verification required', 'unverified player cannot book');
select is(
  (select count(*)::int from public.booking_tickets), 0,
  'other players cannot read tickets');
select is(
  (select count(*)::int from public.bookings), 0,
  'private bookings are hidden from other players');

-- ── Manager of another venue a4 ─────────────────────────────────────────

reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}', true);
set local role authenticated;

select throws_ok(
  $$ select public.confirm_booking((select v from ctx where k = 'b1')::uuid) $$,
  '42501', null, 'manager cannot confirm bookings at another venue');
select throws_ok(
  $$ select * from public.scan_booking_qr((select v from ctx where k = 'qr')) $$,
  'P0002', null, 'manager cannot scan tickets of another venue');

-- ── Manager a2 ──────────────────────────────────────────────────────────

reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;

select is(public.my_role(), 'manager', 'a2 is a manager');
select lives_ok(
  $$ select public.confirm_booking((select v from ctx where k = 'b1')::uuid) $$,
  'manager confirms booking at own venue');
select is(
  (select booker_handle from public.scan_booking_qr((select v from ctx where k = 'qr'))),
  'amineb7', 'scanning the QR returns the booker');
select is(
  (select status::text from public.bookings where id = (select v from ctx where k = 'b1')::uuid),
  'guaranteed', 'scan marks the booking guaranteed');

select lives_ok($$ select public.verify_player('player_00000000a3') $$ ,
  'manager verifies a player by handle');
select lives_ok($$ select public.verify_player('PLAYER_00000000A3') $$,
  'verifying twice is harmless');

reset role;
select is(
  (select coins from public.profiles where id = '00000000-0000-0000-0000-0000000000a3'),
  200, 'verification pays +200 coins exactly once');

-- ── State machine and no-shows ──────────────────────────────────────────

select throws_ok(
  $$ update public.bookings set status = 'requested'
     where id = (select v from ctx where k = 'b1')::uuid $$,
  '23514', null, 'illegal status transitions are blocked even for the owner role');

-- Two no-shows in a row → 7-day booking ban.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select public.mark_no_show((select v from ctx where k = 'b1')::uuid);
reset role;
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, status, total_da)
values ('00000000-0000-0000-0000-0000000000f2', '00000000-0000-0000-0000-00000000b001',
        '00000000-0000-0000-0000-0000000000a1', now() + interval '5 days',
        now() + interval '5 days 1 hour', 'requested', 2500);
update public.bookings set status = 'confirmed' where id = '00000000-0000-0000-0000-0000000000f2';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select public.mark_no_show('00000000-0000-0000-0000-0000000000f2');
reset role;
select ok(
  (select booking_ban_until > now() + interval '6 days' and xp = 1140
   from public.profiles where id = '00000000-0000-0000-0000-0000000000a1'),
  '2 no-shows: -100 XP and a 7-day booking ban');

select * from finish();
rollback;
