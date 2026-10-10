-- Flexible game sizes and the booker cancellation penalty.
-- a1 = verified player (1240 XP, 340 coins), pitch b001 fits up to 7 per side.
begin;
set search_path = public, extensions;
select plan(8);

create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;

insert into ctx values ('b', public.request_booking(
  '00000000-0000-0000-0000-00000000b001', date_trunc('hour', now()) + interval '2 days')::text);
insert into ctx select 'g', id::text from public.games
  where booking_id = (select v from ctx where k = 'b')::uuid;
select is(
  (select per_side::int from public.games where id = (select v from ctx where k = 'g')::uuid),
  7, 'game size defaults to the pitch maximum (7v7)');

select throws_ok(
  $$ select public.request_booking('00000000-0000-0000-0000-00000000b001',
       date_trunc('hour', now()) + interval '3 days', p_per_side => 11::smallint) $$,
  '22023', null, 'cannot book 11v11 on a 7-a-side pitch');

select lives_ok(
  $$ select public.set_game_size((select v from ctx where k = 'g')::uuid, 5::smallint) $$,
  'booker resizes 7v7 to 5v5');
select is(
  (select per_side::int from public.games where id = (select v from ctx where k = 'g')::uuid),
  5, 'size is updated');
select throws_ok(
  $$ select public.set_game_size((select v from ctx where k = 'g')::uuid, 9::smallint) $$,
  '22023', null, 'cannot go above the pitch maximum');

select lives_ok(
  $$ select public.cancel_booking((select v from ctx where k = 'b')::uuid) $$,
  'booker cancels days ahead');
reset role;
select is(
  (select (xp, coins)::text from public.profiles where id = '00000000-0000-0000-0000-0000000000a1'),
  '(1220,330)', 'an early cancellation still costs 20 XP and 10 coins');

-- A manager cancelling doesn't penalise the booker.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
insert into ctx values ('b2', public.request_booking(
  '00000000-0000-0000-0000-00000000b001', date_trunc('hour', now()) + interval '4 days')::text);
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select public.cancel_booking((select v from ctx where k = 'b2')::uuid);
reset role;
select is(
  (select xp from public.profiles where id = '00000000-0000-0000-0000-0000000000a1'),
  1220, 'manager cancellation costs the booker nothing');

select * from finish();
rollback;
