-- Teams: the captain sets the usual game; others cannot change it.
begin;
set search_path = public, extensions;
select plan(5);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003');

-- Captain a1
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select lives_ok(
  $$ insert into public.teams (name, captain_id, per_side)
     values ('Harrach Lions', auth.uid(), 7) $$,
  'player creates a team as captain');
select lives_ok(
  $$ update public.teams set usual_weekday = 2, usual_hour = 21,
       usual_pitch_id = '00000000-0000-0000-0000-00000000b001'
     where name = 'Harrach Lions' $$,
  'captain sets the usual game');
select throws_ok(
  $$ update public.teams set usual_hour = 3 where name = 'Harrach Lions' $$,
  '23514', null, 'hour must be a playing hour');
reset role;

-- Player a3 is not the captain.
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a3","role":"authenticated"}', true);
set local role authenticated;
update public.teams set usual_hour = 18 where name = 'Harrach Lions';
select throws_ok(
  $$ insert into public.team_members (team_id, user_id)
     select id, auth.uid() from public.teams where name = 'Harrach Lions' $$,
  '42501', null, 'only the captain adds members');
reset role;
select is(
  (select usual_hour from public.teams where name = 'Harrach Lions'),
  21::smallint, 'others cannot change the usual game');

select * from finish();
rollback;
