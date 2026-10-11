-- Player reports: only about games both players were in; private to the reporter.
begin;
set search_path = public, extensions;
select plan(6);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, total_da) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() - interval '3 hours', now() - interval '2 hours', 2500);
insert into public.games (id, booking_id, per_side) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000c1', 6);
insert into public.game_players (game_id, user_id, team, position) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a1', 'A', 'mid'),
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a3', 'B', 'gk');

-- Player a1 reports a3 (both played game d1).
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ insert into public.player_reports (reported_id, game_id, reason)
     values ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-0000000000d1', 'no_show') $$,
  'player reports a no-show from their game');
select throws_ok(
  $$ insert into public.player_reports (reported_id, game_id, reason)
     values ('00000000-0000-0000-0000-0000000000a5', '00000000-0000-0000-0000-0000000000d1', 'no_show') $$,
  '42501', null, 'cannot report someone who was not in the game');
select throws_ok(
  $$ insert into public.player_reports (reported_id, reason)
     values ('00000000-0000-0000-0000-0000000000a5', 'no_show') $$,
  '23514', null, 'a no-show report needs a game');
select throws_ok(
  $$ insert into public.player_reports (reporter_id, reported_id, reason)
     values ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-0000000000a5', 'rude') $$,
  '42501', null, 'cannot report in someone else''s name');
reset role;

-- a3 cannot read the report about them; a1 can read their own.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.player_reports), 0, 'reported player cannot see reports');
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.player_reports), 1, 'reporter sees own report');
reset role;

select * from finish();
rollback;
