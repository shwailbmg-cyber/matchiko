-- Referee job board: referees only, one referee per game, no overlaps.
begin;
set search_path = public, extensions;
select plan(8);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');
insert into public.referees (user_id, approved_by, venue_id) values
  ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-0000000000a2',
   (select venue_id from public.pitches where id = '00000000-0000-0000-0000-00000000b001'));
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, total_da, with_referee) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() + interval '2 days', now() + interval '2 days 1 hour', 2700, true),
  ('00000000-0000-0000-0000-0000000000c2', '00000000-0000-0000-0000-00000000b002',
   '00000000-0000-0000-0000-0000000000a5', now() + interval '2 days 30 minutes', now() + interval '2 days 90 minutes', 2700, true);

-- Referee a3
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.open_referee_jobs()), 2, 'referee sees open jobs');
select lives_ok($$ select public.take_referee_job('00000000-0000-0000-0000-0000000000c1') $$,
  'referee takes a job');
select throws_ok($$ select public.take_referee_job('00000000-0000-0000-0000-0000000000c2') $$,
  '22023', null, 'cannot take an overlapping job');
select lives_ok(
  $$ insert into public.referee_availability (weekday, start_hour, end_hour) values (5, 18, 23) $$,
  'referee sets availability');
reset role;

-- Player a5 is not a referee.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a5","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select * from public.open_referee_jobs() $$,
  '42501', null, 'non-referees cannot list jobs');
select throws_ok($$ select public.take_referee_job('00000000-0000-0000-0000-0000000000c2') $$,
  '42501', null, 'non-referees cannot take jobs');
select throws_ok(
  $$ insert into public.referee_availability (weekday, start_hour, end_hour) values (5, 18, 23) $$,
  '42501', null, 'non-referees cannot set availability');
reset role;
select is(
  (select referee_id from public.bookings where id = '00000000-0000-0000-0000-0000000000c1'),
  '00000000-0000-0000-0000-0000000000a3'::uuid, 'the job is assigned');

select * from finish();
rollback;
