-- Rewards after a game: show-up, one-time first-game bonus, absent penalty,
-- rating reward paid once. a1 = player (1240 XP, 340 coins), a2 = manager.
begin;
set search_path = public, extensions;
select plan(9);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003');

select is((select count(*)::int from public.reward_rules), 13, 'every reward reason has a rule');
select is((select count(*)::int from public.cities), 69, 'the 69 wilayas ship with the migrations');

-- Two past games at the manager's venue: a1 plays both, a3 skips the first.
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, total_da) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() - interval '3 hours', now() - interval '2 hours', 2500),
  ('00000000-0000-0000-0000-0000000000c2', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() - interval '2 hours', now() - interval '1 hour', 2500);
update public.bookings set status = 'guaranteed'
  where id in ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-0000000000c2');
insert into public.games (id, booking_id, per_side) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000c1', 6),
  ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-0000000000c2', 6);
insert into public.game_players (game_id, user_id, team, position) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a1', 'A', 'mid'),
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a3', 'B', 'gk'),
  ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-0000000000a1', 'A', 'mid');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ select public.complete_booking('00000000-0000-0000-0000-0000000000c1',
       array['00000000-0000-0000-0000-0000000000a3']::uuid[]) $$,
  'manager completes the first game, marking a3 absent');
select public.complete_booking('00000000-0000-0000-0000-0000000000c2');
reset role;

select is(
  (select xp from public.profiles where id = '00000000-0000-0000-0000-0000000000a1'),
  1240 + 30 + 50 + 30, 'two show-ups and the first-game bonus only once');
select is(
  (select coins from public.profiles where id = '00000000-0000-0000-0000-0000000000a1'),
  340 + 20 + 20, 'show-up coins for each game');
select is(
  (select no_show_count from public.profiles where id = '00000000-0000-0000-0000-0000000000a3'),
  1, 'absent player gets a no-show');
select is(
  (select xp from public.profiles where id = '00000000-0000-0000-0000-0000000000a3'),
  0, 'XP never goes below zero');

-- Rating pays +10 coins once per game.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ select public.rate_game('00000000-0000-0000-0000-0000000000d1', 5::smallint, '{clean}',
       '[{"user_id":"00000000-0000-0000-0000-0000000000a3","stars":2,"tags":["late"]}]') $$,
  'player rates the pitch and another player');
select public.rate_game('00000000-0000-0000-0000-0000000000d1', 4::smallint);
reset role;
select is(
  (select coins from public.profiles where id = '00000000-0000-0000-0000-0000000000a1'),
  340 + 20 + 20 + 10, 'rating reward is paid once per game');

select * from finish();
rollback;
