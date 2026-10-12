-- Public profiles show the reliability % (attended / finished games),
-- never the raw no-show count.
create or replace function public.player_json(p_user uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'handle', p.handle, 'name', p.full_name, 'wilaya_id', p.city_id,
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
