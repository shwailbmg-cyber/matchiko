-- Manager calendar: blocks and walk-ins are manager-only and never overlap bookings.
begin;
set search_path = public, extensions;
select plan(8);

create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;
insert into ctx values ('t', (date_trunc('hour', now()) + interval '3 days')::text);

-- Manager a2 (venue of pitch b001)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ insert into public.pitch_blocks (pitch_id, starts_at, ends_at, kind, label, phone)
     select '00000000-0000-0000-0000-00000000b001', v::timestamptz, v::timestamptz + interval '1 hour',
            'walk_in', 'Karim', '+213555000111' from ctx where k = 't' $$,
  'manager adds a walk-in booking');
select throws_ok(
  $$ insert into public.pitch_blocks (pitch_id, starts_at, ends_at, kind)
     select '00000000-0000-0000-0000-00000000b001', v::timestamptz + interval '30 minutes',
            v::timestamptz + interval '90 minutes', 'blocked' from ctx where k = 't' $$,
  '23P01', null, 'blocks cannot overlap');
reset role;

-- Player a1
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.pitch_blocks), 0, 'players cannot read blocks (names, phones)');
select throws_ok(
  $$ insert into public.pitch_blocks (pitch_id, starts_at, ends_at, kind)
     values ('00000000-0000-0000-0000-00000000b001', now() + interval '5 days',
             now() + interval '5 days 1 hour', 'blocked') $$,
  '42501', null, 'players cannot block slots');
select throws_ok(
  $$ select public.request_booking('00000000-0000-0000-0000-00000000b001',
       (select v::timestamptz from ctx where k = 't')) $$,
  '23P01', null, 'players cannot book a blocked slot');
select is(
  (select count(*)::int from public.pitch_busy('00000000-0000-0000-0000-00000000b001',
     now(), now() + interval '7 days')),
  1, 'players see the hour as busy');
insert into ctx values ('b', public.request_booking('00000000-0000-0000-0000-00000000b001',
  (select v::timestamptz + interval '2 hours' from ctx where k = 't'))::text);
reset role;

-- The manager cannot block over that booking.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ insert into public.pitch_blocks (pitch_id, starts_at, ends_at, kind)
     select '00000000-0000-0000-0000-00000000b001', v::timestamptz + interval '2 hours',
            v::timestamptz + interval '3 hours', 'blocked' from ctx where k = 't' $$,
  '23P01', null, 'cannot block a booked slot');
reset role;
select throws_ok(
  $$ select * from public.pitch_busy('00000000-0000-0000-0000-00000000b001', now(), now() + interval '30 days') $$,
  '22023', null, 'busy range is limited to 8 days');

select * from finish();
rollback;
