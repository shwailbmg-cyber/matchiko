-- Bookings only inside the venue's opening hours.
begin;
set search_path = public, extensions;
select plan(3);

update public.venues set open_hour = 10, close_hour = 22
  where id = '00000000-0000-0000-0000-00000000a001';

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.request_booking('00000000-0000-0000-0000-00000000b001',
  (date_trunc('day', now() at time zone 'Africa/Algiers') + interval '2 days 9 hours')
    at time zone 'Africa/Algiers') $$,
  '22023', 'venue closed at that time', 'not before opening');
select throws_ok($$ select public.request_booking('00000000-0000-0000-0000-00000000b001',
  (date_trunc('day', now() at time zone 'Africa/Algiers') + interval '2 days 22 hours')
    at time zone 'Africa/Algiers') $$,
  '22023', 'venue closed at that time', 'the game must end by closing time');
select lives_ok($$ select public.request_booking('00000000-0000-0000-0000-00000000b001',
  (date_trunc('day', now() at time zone 'Africa/Algiers') + interval '2 days 21 hours')
    at time zone 'Africa/Algiers') $$,
  'the last hour before closing is fine');
reset role;

select * from finish();
rollback;
