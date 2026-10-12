-- Branch security review fixes.
begin;
set search_path = public, extensions;
select plan(8);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');
create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;

-- A started game: a3 played in it and cannot leave it afterwards.
insert into public.bookings (id, pitch_id, booker_id, starts_at, ends_at, total_da, status) values
  ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000b001',
   '00000000-0000-0000-0000-0000000000a1', now() - interval '30 minutes',
   now() + interval '30 minutes', 2500, 'requested');
insert into public.games (id, booking_id, per_side) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000c1', 5);
insert into public.game_players (game_id, user_id, team, position) values
  ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a3', 'B', 'mid');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.confirm_coming('00000000-0000-0000-0000-0000000000d1', false) $$,
  '22023', 'game already started', 'no leaving after kick-off');

-- Friend request sent, deleted, sent again: one notification.
insert into public.friendships (addressee_id) values ('00000000-0000-0000-0000-0000000000a5');
delete from public.friendships where addressee_id = '00000000-0000-0000-0000-0000000000a5';
insert into public.friendships (addressee_id) values ('00000000-0000-0000-0000-0000000000a5');

-- Six devices: only the 5 newest stay.
select public.register_push_token('device-token-000000000000' || i, 'android')
  from generate_series(1, 6) i;
select is((select count(*)::int from public.push_tokens), 5, 'at most 5 devices');
reset role;
select is((select count(*)::int from public.notifications
           where user_id = '00000000-0000-0000-0000-0000000000a5' and kind = 'friend_request'),
  1, 'one friend request notification per day');

-- a1 opens a game, closes it, opens it again: friend a5 hears once.
insert into public.friendships (requester_id, addressee_id, status) values
  ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-0000000000a5', 'accepted');
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
insert into ctx values ('b', public.request_booking('00000000-0000-0000-0000-00000000b001',
  date_trunc('hour', now()) + interval '2 days')::text);
insert into ctx select 'g', id::text from public.games where booking_id = (select v from ctx where k = 'b')::uuid;
select public.set_game_open((select v::uuid from ctx where k = 'g'), true);
select public.set_game_open((select v::uuid from ctx where k = 'g'), false);
select public.set_game_open((select v::uuid from ctx where k = 'g'), true);
reset role;
select is((select count(*)::int from public.notifications
           where user_id = '00000000-0000-0000-0000-0000000000a5' and kind = 'spot_open'),
  1, 'one spot-open notification per game');

-- "Who sees my games": a1 (friends only) is hidden from stranger a3,
-- visible to friend a5 and to a1 itself.
update public.profiles set games_visibility = 'friends'
  where id = '00000000-0000-0000-0000-0000000000a1';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select public.open_games() limit 1) -> 'players' -> 0 ->> 'handle', '',
  'strangers do not see a friends-only player');
select is((select public.open_games() limit 1) -> 'players' -> 0 ->> 'guest', 'true',
  'shown as a guest');
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a5","role":"authenticated"}', true);
set local role authenticated;
select isnt((select public.open_games() limit 1) -> 'players' -> 0 ->> 'handle', '',
  'friends see them');
reset role;
insert into public.game_players (game_id, user_id, team, position)
  select v::uuid, '00000000-0000-0000-0000-0000000000a3', 'B', 'gk' from ctx where k = 'g';
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select isnt(public.game_detail((select v::uuid from ctx where k = 'g')) -> 'players' -> 0 ->> 'handle', '',
  'players of the game see everyone');
reset role;

select * from finish();
rollback;
