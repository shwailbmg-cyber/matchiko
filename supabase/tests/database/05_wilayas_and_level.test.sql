-- Wilayas reference data and the self-rated level on profiles.
begin;
set search_path = public, extensions;
select plan(6);

select is((select count(*)::int from public.cities), 69, 'all 69 wilayas');
select is(
  (select array_agg(code order by code) from public.cities),
  (select array_agg(g::smallint) from generate_series(1, 69) g),
  'codes are 1 to 69 with no gap');

-- Player a1 (seed)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ update public.profiles set level = 'good', city_id = 'bou_saada' where id = auth.uid() $$,
  'player sets own level and wilaya');
select is((select level from public.get_my_profile()), 'good', 'player reads own level');
select throws_ok(
  $$ update public.profiles set level = 'pro' where id = auth.uid() $$,
  '23514', null, 'level must be one of the four values');
select throws_ok(
  $$ insert into public.cities (id, code, name_fr, name_ar) values ('x', 70, 'X', 'X') $$,
  '42501', null, 'players cannot add wilayas');
reset role;

select * from finish();
rollback;
