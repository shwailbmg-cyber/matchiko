-- Settings, blocking, support messages and account deletion.
begin;
set search_path = public, extensions;
select plan(10);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003'),
  ('00000000-0000-0000-0000-0000000000a5', '213555000005');

-- Player a3
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ update public.profiles set games_visibility = 'nobody', notify_nearby = false where id = auth.uid() $$,
  'player changes privacy and notifications');
select is((select games_visibility from public.get_my_settings()), 'nobody', 'player reads own settings');
select throws_ok($$ update public.profiles set games_visibility = 'all' where id = auth.uid() $$,
  '23514', null, 'visibility has three values');
select lives_ok($$ insert into public.blocked_users (blocked_id) values ('00000000-0000-0000-0000-0000000000a5') $$,
  'player blocks someone');
select lives_ok($$ insert into public.support_messages (message) values ('The map does not load.') $$,
  'player reports a problem');
reset role;

-- Player a5 (blocked by a3)
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a5","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ insert into public.friendships (addressee_id) values ('00000000-0000-0000-0000-0000000000a3') $$,
  '42501', null, 'a blocked player cannot send a friend request');
select is((select count(*)::int from public.blocked_users), 0, 'blocked players cannot see who blocked them');
select is((select count(*)::int from public.support_messages), 0, 'support messages are private');
reset role;

-- Manager a2 is the only manager of their venue.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a2","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.delete_my_account() $$,
  '22023', null, 'the only manager cannot delete their account');
reset role;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select public.delete_my_account();
reset role;
select is((select count(*)::int from auth.users where id = '00000000-0000-0000-0000-0000000000a3'),
  0, 'a player deletes their account');

select * from finish();
rollback;
