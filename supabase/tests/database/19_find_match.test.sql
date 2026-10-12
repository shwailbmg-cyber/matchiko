-- Matchmaking: best open game, never my own, never with a blocked player.
begin;
set search_path = public, extensions;
select plan(5);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');
create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;

-- a1 books two open games: one tomorrow, one in 3 days.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
insert into ctx values
  ('b1', public.request_booking('00000000-0000-0000-0000-00000000b001',
     date_trunc('hour', now()) + interval '1 day')::text),
  ('b2', public.request_booking('00000000-0000-0000-0000-00000000b001',
     date_trunc('hour', now()) + interval '3 days')::text);
insert into ctx select 'g1', id::text from public.games where booking_id = (select v from ctx where k = 'b1')::uuid;
insert into ctx select 'g2', id::text from public.games where booking_id = (select v from ctx where k = 'b2')::uuid;
select public.set_game_open((select v::uuid from ctx where k = 'g1'), true);
select public.set_game_open((select v::uuid from ctx where k = 'g2'), true);
select is(public.find_match('{mid}'), null, 'never my own game');
reset role;

-- a5 is a friend of a3 and plays in the later game.
insert into public.friendships (requester_id, addressee_id, status) values
  ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-0000000000a5', 'accepted');
insert into public.game_players (game_id, user_id, team, position)
  select v::uuid, '00000000-0000-0000-0000-0000000000a5', 'A', 'gk' from ctx where k = 'g2';

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is(public.find_match('{mid}') ->> 'id', (select v from ctx where k = 'g1'),
  'the sooner game wins on time');
select ok(public.find_match('{gk,mid}') is not null, 'a keeper gets an offer');
reset role;

-- a3 blocks a1 (the booker in both games): nothing to offer.
insert into public.blocked_users (blocker_id, blocked_id) values
  ('00000000-0000-0000-0000-0000000000a3', '00000000-0000-0000-0000-0000000000a1');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is(public.find_match('{mid}'), null, 'never with a blocked player');
reset role;

set local role anon;
select throws_ok($$ select public.find_match('{mid}') $$, '42501', null, 'anon cannot search');
reset role;

select * from finish();
rollback;
