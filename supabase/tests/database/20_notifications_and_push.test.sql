-- Server-written inbox and device tokens.
begin;
set search_path = public, extensions;
select plan(10);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');
create temp table ctx (k text primary key, v text);
grant all on ctx to authenticated;

-- a3 asks a1 to be friends → a1 gets a friend request.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
insert into public.friendships (addressee_id) values ('00000000-0000-0000-0000-0000000000a1');
reset role;
update public.friendships set status = 'accepted';
select is((select count(*)::int from public.notifications
           where user_id = '00000000-0000-0000-0000-0000000000a1' and kind = 'friend_request'),
  1, 'friend request reaches the addressee');

-- a1 books in 2–3 hours and opens the game → friend a3 hears about it.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
insert into ctx values ('b', public.request_booking('00000000-0000-0000-0000-00000000b001',
  date_trunc('hour', now()) + interval '3 hours')::text);
insert into ctx select 'g', id::text from public.games where booking_id = (select v from ctx where k = 'b')::uuid;
select public.set_game_open((select v::uuid from ctx where k = 'g'), true);
reset role;
select is((select payload ->> 'game_id' from public.notifications
           where user_id = '00000000-0000-0000-0000-0000000000a3' and kind = 'spot_open'),
  (select v from ctx where k = 'g'), 'friends hear about the open game');

-- Manager confirms → booker is told.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select public.confirm_booking((select v::uuid from ctx where k = 'b'));
reset role;
select is((select count(*)::int from public.notifications
           where user_id = '00000000-0000-0000-0000-0000000000a1' and kind = 'booking_confirmed'),
  1, 'booker hears the booking is confirmed');

-- Reminders: once per player and game.
select is(public.send_reminders(), 1, 'one reminder for the booker');
select is(public.send_reminders(), 0, 'never twice');
select throws_ok($$ set local role authenticated; select public.send_reminders() $$,
  '42501', null, 'players cannot send reminders');
reset role;

-- Device tokens: own rows only; a token moves to the last account.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select public.register_push_token('device-token-0123456789', 'android');
select is((select count(*)::int from public.push_tokens), 1, 'I see my token');
select throws_ok($$ insert into public.push_tokens (token, user_id, platform)
  values ('x123456789012345678901', '00000000-0000-0000-0000-0000000000a1', 'web') $$,
  '42501', null, 'no direct writes');
reset role;
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a5","role":"authenticated"}', true);
set local role authenticated;
select is((select count(*)::int from public.push_tokens), 0, 'not someone else''s tokens');
select public.register_push_token('device-token-0123456789', 'android');
reset role;
select is((select user_id::text from public.push_tokens),
  '00000000-0000-0000-0000-0000000000a5', 'token follows the last sign-in');

select * from finish();
rollback;
