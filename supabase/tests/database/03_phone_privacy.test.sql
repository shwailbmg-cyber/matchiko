-- Phone numbers: private to the owner and to managers of venues they booked.
begin;
set search_path = public, extensions;
select plan(6);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a4', '213555000004');
insert into public.venues (id, name, city_id) values
  ('00000000-0000-0000-0000-00000000a009', 'Other venue', 'oran');
insert into public.venue_managers (venue_id, user_id) values
  ('00000000-0000-0000-0000-00000000a009', '00000000-0000-0000-0000-0000000000a4');
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, total_da) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() + interval '1 day',
   now() + interval '1 day 1 hour', 2500);

-- Player a1
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ select phone from public.profiles $$,
  '42501', null, 'players cannot read phone numbers from profiles');
select throws_ok(
  $$ update public.profiles set phone = '0555123456' where id = auth.uid() $$,
  '23514', null, 'phone must be +213 mobile format');
select lives_ok(
  $$ update public.profiles set phone = '+213661000000' where id = auth.uid() $$,
  'player sets own phone');
select is((select phone from public.get_my_profile()), '+213661000000', 'player reads own phone');
reset role;

-- Manager of the booking's venue vs another manager
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select is(
  (select phone from public.booking_contact('00000000-0000-0000-0000-0000000000c1')),
  '+213661000000', 'venue manager gets the booker''s phone to call');
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}', true);
set local role authenticated;
select throws_ok(
  $$ select * from public.booking_contact('00000000-0000-0000-0000-0000000000c1') $$,
  '42501', null, 'other managers cannot read it');
reset role;

select * from finish();
rollback;
