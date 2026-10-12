-- Favourite pitches are private to their owner.
begin;
set search_path = public, extensions;
select plan(5);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003');

-- Player a1 (seed)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ insert into public.favorite_pitches (pitch_id) values ('00000000-0000-0000-0000-00000000b001') $$,
  'player adds a favourite');
select is((select count(*)::int from public.favorite_pitches), 1, 'player sees own favourite');
reset role;

-- Player a3
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.favorite_pitches), 0, 'others cannot see it');
select throws_ok(
  $$ insert into public.favorite_pitches (user_id, pitch_id)
     values ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000b001') $$,
  '42501', null, 'cannot add a favourite for someone else');
delete from public.favorite_pitches;
reset role;
select is((select count(*)::int from public.favorite_pitches), 1, 'others cannot delete it');

select * from finish();
rollback;
