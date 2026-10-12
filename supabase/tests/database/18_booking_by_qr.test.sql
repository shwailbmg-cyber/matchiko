-- Booking QR lookup: own venue only.
begin;
set search_path = public, extensions;
select plan(3);

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
insert into public.games (booking_id, per_side) values
  ('00000000-0000-0000-0000-0000000000c1', 7);
insert into public.booking_tickets (booking_id, qr_token) values
  ('00000000-0000-0000-0000-0000000000c1', 'tok-1');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select is((public.booking_by_qr('tok-1')->>'per_side')::int, 7, 'manager reads the booking');
reset role;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.booking_by_qr('tok-1') $$, 'P0002', null,
  'another venue''s manager cannot');
reset role;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.booking_by_qr('nope') $$, 'P0002', null,
  'unknown token');
reset role;

select * from finish();
rollback;
