-- Avatars: own file only, and the profile path is set by the server.
begin;
set search_path = public, extensions;
select plan(5);

select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', true);
set local role authenticated;
select lives_ok($$ insert into storage.objects (bucket_id, name)
  values ('avatars', '00000000-0000-0000-0000-0000000000a1/avatar.jpg') $$, 'upload my photo');
select throws_ok($$ insert into storage.objects (bucket_id, name)
  values ('avatars', '00000000-0000-0000-0000-0000000000a2/avatar.jpg') $$,
  '42501', null, 'not into someone else''s folder');
select matches(public.set_my_avatar(),
  '^00000000-0000-0000-0000-0000000000a1/avatar\.jpg\?v=[0-9]+$', 'server sets the path');
select throws_ok($$ update public.profiles set avatar_url = 'https://evil.example/pixel.gif'
  where id = auth.uid() $$, '42501', null, 'no outside photo URL');
select is(public.set_my_avatar(true), null, 'remove my photo');
reset role;

select * from finish();
rollback;
