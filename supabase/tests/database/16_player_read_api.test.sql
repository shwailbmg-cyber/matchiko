-- Read API: no private fields, friendship status from the caller's side.
begin;
set search_path = public, extensions;
select plan(8);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003');
update public.profiles set full_name = 'Riad Test' where id = '00000000-0000-0000-0000-0000000000a3';

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select ok((select count(*) from public.list_pitches()) >= 3, 'pitches list');
select is((select count(*)::int from public.find_players('riad')), 1, 'find a player by name');
select ok(not ((select public.find_players('riad') limit 1) ? 'phone'), 'no phone in the public player');
select ok(not ((select public.find_players('riad') limit 1) ? 'coins'), 'no coins in the public player');
insert into public.friendships (addressee_id) values ('00000000-0000-0000-0000-0000000000a3');
select is((select public.find_players('riad') limit 1) ->> 'friend', 'sent', 'request shows as sent for me');
insert into public.teams (name, captain_id, per_side) values ('Lions', auth.uid(), 7);
select is((select public.my_teams() limit 1) ->> 'i_am_captain', 'true', 'my team, I am captain');
reset role;

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
select is((select public.my_friends() limit 1) ->> 'friend', 'incoming', 'and as incoming for them');
select throws_ok($$ select public.get_player('nobody_x') $$, 'P0002', null, 'unknown handle');
reset role;

select * from finish();
rollback;
