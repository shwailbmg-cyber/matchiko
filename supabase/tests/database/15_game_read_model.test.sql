-- Game JSON for the app, and the booker's game-page tools.
begin;
set search_path = public, extensions;
select plan(11);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');
create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;

-- Booker a1 books, opens the game.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
insert into ctx values ('b', public.request_booking(
  '00000000-0000-0000-0000-00000000b001', date_trunc('hour', now()) + interval '2 days')::text);
insert into ctx select 'g', id::text from public.games where booking_id = (select v from ctx where k = 'b')::uuid;
select lives_ok($$ select public.set_game_open((select v::uuid from ctx where k = 'g'), true) $$,
  'booker opens the game');
select is(jsonb_array_length((select public.my_games() limit 1) -> 'players'), 1, 'my game lists me');
select is((select public.my_games() limit 1) -> 'players' -> 0 ->> 'is_booker', 'true', 'I am the booker');
select ok(length((select public.my_games() limit 1) ->> 'code') > 0, 'booker sees the QR token');
reset role;

-- Player a3 finds and joins it.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.open_games()), 1, 'others see the open game');
select is((select public.open_games() limit 1) ->> 'code', '', 'others never get the QR token');
select public.join_open_game((select v::uuid from ctx where k = 'g'), 'gk');
select throws_ok($$ select public.set_player_paid((select v::uuid from ctx where k = 'g'), 'x', true) $$,
  '42501', null, 'only the booker marks who paid');
select lives_ok($$ select public.confirm_coming((select v::uuid from ctx where k = 'g'), false) $$,
  'a player who cannot come frees the spot');
reset role;
select is((select count(*)::int from public.game_players where game_id = (select v::uuid from ctx where k = 'g')),
  1, 'the spot is free again');

-- Outsider a5 cannot read a closed game.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select public.set_game_open((select v::uuid from ctx where k = 'g'), false);
select throws_ok($$ select public.confirm_coming((select v::uuid from ctx where k = 'g'), false) $$,
  '22023', null, 'the booker cancels instead of leaving');
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a5","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.game_detail((select v::uuid from ctx where k = 'g')) $$,
  'P0002', null, 'outsiders cannot read a closed game');
reset role;

select * from finish();
rollback;
