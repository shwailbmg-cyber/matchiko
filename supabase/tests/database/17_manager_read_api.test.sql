-- Manager read API: own venue only.
begin;
set search_path = public, extensions;
select plan(7);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a4', '213555000004');
insert into public.venues (id, name, city_id) values
  ('00000000-0000-0000-0000-00000000a009', 'Other venue', 'oran');
insert into public.venue_managers (venue_id, user_id) values
  ('00000000-0000-0000-0000-00000000a009', '00000000-0000-0000-0000-0000000000a4');
insert into public.verification_requests (user_id, venue_id)
  select '00000000-0000-0000-0000-0000000000a3', venue_id from public.pitches
  where id = '00000000-0000-0000-0000-00000000b001';
insert into public.bookings (pitch_id, booker_id, starts_at, ends_at, total_da) values
  ('00000000-0000-0000-0000-00000000b001', '00000000-0000-0000-0000-0000000000a1',
   date_trunc('day', now() at time zone 'Africa/Algiers') at time zone 'Africa/Algiers' + interval '23 hours',
   date_trunc('day', now() at time zone 'Africa/Algiers') at time zone 'Africa/Algiers' + interval '24 hours', 2500);
insert into public.games (booking_id, per_side)
  select id, 7 from public.bookings where pitch_id = '00000000-0000-0000-0000-00000000b001';

-- Venue manager a2
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.venue_today()), 1, 'today''s game at my venue');
select is((select count(*)::int from public.verification_queue()), 1, 'my verification queue');
select is((select count(*)::int from public.venue_week('00000000-0000-0000-0000-00000000b001',
  now() - interval '1 day')), 1, 'my week calendar');
reset role;

-- Other venue's manager a4
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.venue_today()), 0, 'not another venue''s games');
select is((select count(*)::int from public.verification_queue()), 0, 'not another venue''s queue');
select throws_ok($$ select * from public.venue_week('00000000-0000-0000-0000-00000000b001', now()) $$,
  '42501', null, 'not another venue''s calendar');
reset role;

-- A player has no referee jobs.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.my_referee_jobs()), 0, 'no jobs for a player');
reset role;

select * from finish();
rollback;
