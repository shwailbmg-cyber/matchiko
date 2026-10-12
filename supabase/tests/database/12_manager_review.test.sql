-- Managers review reports and check players in, only at their venue.
begin;
set search_path = public, extensions;
select plan(8);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a4', '213555000004');
insert into public.venues (id, name, city_id) values
  ('00000000-0000-0000-0000-00000000a009', 'Other venue', 'oran');
insert into public.venue_managers (venue_id, user_id) values
  ('00000000-0000-0000-0000-00000000a009', '00000000-0000-0000-0000-0000000000a4');
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, total_da) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() - interval '3 hours', now() - interval '2 hours', 2500);
insert into public.games (id, booking_id, per_side) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000c1', 6);
insert into public.game_players (game_id, user_id, team, position) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a1', 'A', 'mid'),
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a3', 'B', 'gk');
insert into public.player_reports (reporter_id, reported_id, game_id, reason) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000a3',
   '00000000-0000-0000-0000-0000000000d1', 'no_show');

-- Another venue's manager a4
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a4","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.player_reports), 0, 'other managers do not see the report');
select throws_ok($$ select public.review_player_report((select max(id) from public.player_reports), true) $$,
  'P0002', null, 'other managers cannot review it');
select throws_ok($$ select public.check_in_player('00000000-0000-0000-0000-0000000000d1', 'x') $$,
  '42501', null, 'other managers cannot check players in');
reset role;

-- Venue manager a2
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.player_reports), 1, 'venue manager sees the report');
select lives_ok($$ select public.review_player_report((select max(id) from public.player_reports), true) $$,
  'venue manager accepts the no-show');
select throws_ok($$ select public.review_player_report((select max(id) from public.player_reports), true) $$,
  '22023', null, 'a report is reviewed once');
reset role;
select is((select no_show_count from public.profiles where id = '00000000-0000-0000-0000-0000000000a3'),
  1, 'the no-show penalty applied');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ select public.check_in_player('00000000-0000-0000-0000-0000000000d1',
  (select handle from public.profiles where id = '00000000-0000-0000-0000-0000000000a1')) $$,
  'venue manager checks a player in');
reset role;

select * from finish();
rollback;
