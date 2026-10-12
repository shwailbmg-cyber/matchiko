-- Profile photos in a public `avatars` bucket, one file per user at
-- <user id>/avatar.jpg. The profile stores only that path (set by the
-- server), so nobody can point their photo at an outside URL that tracks
-- who looks at it.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('avatars', 'avatars', true, 524288, array['image/jpeg'])
on conflict (id) do nothing;

create policy "avatar read own" on storage.objects for select to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy "avatar upload own" on storage.objects for insert to authenticated
  with check (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');
create policy "avatar replace own" on storage.objects for update to authenticated
  using (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');
create policy "avatar delete own" on storage.objects for delete to authenticated
  using (bucket_id = 'avatars' and name = (select auth.uid())::text || '/avatar.jpg');

alter table public.profiles drop constraint profiles_avatar_url_check;
update public.profiles set avatar_url = null;
alter table public.profiles add constraint profiles_avatar_url_check
  check (avatar_url is null or avatar_url ~ '^[0-9a-f-]{36}/avatar\.jpg\?v=[0-9]+$');
revoke update (avatar_url) on public.profiles from authenticated;

-- After uploading (or with p_remove, after deleting) the photo.
-- ?v= changes on each upload so phones don't show the cached old photo.
create function public.set_my_avatar(p_remove boolean default false)
returns text
language sql
security definer
set search_path = ''
as $$
  update public.profiles
  set avatar_url = case when p_remove then null
                        else id::text || '/avatar.jpg?v=' || extract(epoch from now())::bigint end
  where id = (select auth.uid())
  returning avatar_url;
$$;

revoke all on function public.set_my_avatar(boolean) from public, anon;
grant execute on function public.set_my_avatar(boolean) to authenticated;

-- Public profiles carry the photo path too.
create or replace function public.player_json(p_user uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'handle', p.handle, 'name', p.full_name, 'wilaya_id', p.city_id,
    'avatar', p.avatar_url,
    'positions', to_jsonb(p.positions), 'xp', p.xp,
    'verified', p.verified_at is not null,
    'played', (select count(*) from public.game_players gp
               where gp.user_id = p.id and gp.attended),
    'reliability', public.reliability_of(p.id),
    'friend', coalesce((
      select case
        when f.status = 'accepted' then 'friends'
        when f.requester_id = (select auth.uid()) then 'sent'
        else 'incoming' end
      from public.friendships f
      where (f.requester_id = (select auth.uid()) and f.addressee_id = p.id)
         or (f.addressee_id = (select auth.uid()) and f.requester_id = p.id)
      limit 1), 'none'))
  from public.profiles p where p.id = p_user;
$$;
