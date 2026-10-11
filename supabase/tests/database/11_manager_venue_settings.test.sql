-- Managers edit only their own venue and pitches, within the checks.
begin;
set search_path = public, extensions;
select plan(5);

-- Manager a2 (venue of pitch b001)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ update public.pitches set price_da = 2800, features = '{light,shower}'
     where id = '00000000-0000-0000-0000-00000000b001' $$,
  'manager changes price and amenities');
select lives_ok(
  $$ update public.venues set open_hour = 9, close_hour = 23
     where id = (select venue_id from public.pitches where id = '00000000-0000-0000-0000-00000000b001') $$,
  'manager changes opening hours');
select throws_ok(
  $$ update public.pitches set price_da = 0 where id = '00000000-0000-0000-0000-00000000b001' $$,
  '23514', null, 'price must be positive');
update public.pitches set price_da = 1 where id = '00000000-0000-0000-0000-00000000b002';
reset role;
select isnt((select price_da from public.pitches where id = '00000000-0000-0000-0000-00000000b002'),
  1, 'managers cannot change another venue''s pitches');

-- Player a1
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
update public.pitches set price_da = 1 where id = '00000000-0000-0000-0000-00000000b001';
reset role;
select is((select price_da from public.pitches where id = '00000000-0000-0000-0000-00000000b001'),
  2800, 'players cannot change prices');

select * from finish();
rollback;
