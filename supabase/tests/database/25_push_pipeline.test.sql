-- Push pipeline: the secret is server-only; inserts work without pg_net.
begin;
set search_path = public, extensions;
select plan(3);

select lives_ok($$ insert into public.notifications (user_id, kind)
  values ('00000000-0000-0000-0000-0000000000a1', 'rate_game') $$,
  'notifications insert fine when pg_net is missing');

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select throws_ok($$ select public.push_webhook_secret() $$, '42501', null,
  'players cannot read the push secret');
select throws_ok($$ select public.notify_push() $$, '42501', null,
  'players cannot call the trigger function');
reset role;

select * from finish();
rollback;
