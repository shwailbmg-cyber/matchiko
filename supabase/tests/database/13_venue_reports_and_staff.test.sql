-- Reports and staff: managers of the venue only; a venue keeps one manager.
begin;
set search_path = public, extensions;
select plan(8);

create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;
insert into ctx select 'venue', venue_id::text from public.pitches
  where id = '00000000-0000-0000-0000-00000000b001';
insert into public.bookings (pitch_id, booker_id, starts_at, ends_at, total_da, status) values
  ('00000000-0000-0000-0000-00000000b001', '00000000-0000-0000-0000-0000000000a1',
   now() - interval '2 days', now() - interval '2 days' + interval '1 hour', 2500, 'requested');
update public.bookings set status = 'guaranteed'
  where pitch_id = '00000000-0000-0000-0000-00000000b001' and starts_at < now() - interval '1 day';
insert into public.bookings (pitch_id, booker_id, starts_at, ends_at, total_da) values
  ('00000000-0000-0000-0000-00000000b001', '00000000-0000-0000-0000-0000000000a1',
   now() + interval '1 day', now() + interval '1 day 1 hour', 2500);
update public.bookings set status = 'confirmed'
  where pitch_id = '00000000-0000-0000-0000-00000000b001' and starts_at > now();

-- Venue manager a2
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select is((select cash_expected_da from public.venue_report((select v::uuid from ctx where k = 'venue'),
  now() - interval '7 days', now() + interval '7 days')), 5000, 'cash expected counts confirmed and paid');
select is((select cash_received_da from public.venue_report((select v::uuid from ctx where k = 'venue'),
  now() - interval '7 days', now() + interval '7 days')), 2500, 'cash received counts paid only');
select is((select booked_hours from public.venue_report((select v::uuid from ctx where k = 'venue'),
  now() - interval '7 days', now() + interval '7 days')), 2, 'booked hours');
select is((select count(*)::int from public.venue_staff((select v::uuid from ctx where k = 'venue'))),
  1, 'manager sees the staff');
select throws_ok(
  $$ select public.remove_venue_manager((select v::uuid from ctx where k = 'venue'),
       (select handle from public.profiles where id = '00000000-0000-0000-0000-0000000000a2')) $$,
  '22023', null, 'the last manager cannot be removed');
select lives_ok(
  $$ select public.add_venue_manager((select v::uuid from ctx where k = 'venue'),
       (select handle from public.profiles where id = '00000000-0000-0000-0000-0000000000a1')) $$,
  'manager adds a verified player as staff');
reset role;

-- Player a3 (not a manager)
insert into auth.users (id, phone) values ('00000000-0000-0000-0000-0000000000a3', '213555000003');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select * from public.venue_report((select v::uuid from ctx where k = 'venue'), now() - interval '1 day', now()) $$,
  '42501', null, 'players cannot read venue reports');
select throws_ok($$ select public.add_venue_manager((select v::uuid from ctx where k = 'venue'), 'x') $$,
  '42501', null, 'players cannot add managers');
reset role;

select * from finish();
rollback;
