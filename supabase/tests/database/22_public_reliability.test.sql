-- Public player: reliability %, never the raw no-show count.
begin;
set search_path = public, extensions;
select plan(2);

insert into auth.users (id, phone) values
  ('00000000-0000-0000-0000-0000000000a3', '213555000003');
update public.profiles set full_name = 'Riad Test' where id = '00000000-0000-0000-0000-0000000000a3';

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select is(((select public.find_players('riad') limit 1) ->> 'reliability')::int, 100,
  'new players start at 100%');
select ok(not ((select public.find_players('riad') limit 1) ? 'no_shows'),
  'no raw no-show count');
reset role;

select * from finish();
rollback;
