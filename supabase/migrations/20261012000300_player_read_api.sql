-- Read API for the app's player screens: pitches, players with my
-- friendship status, friends, teams, blocked list, profile stats. JSON
-- shapes match the Flutter models (snake_case keys).

-- ── Pitches ─────────────────────────────────────────────────────────────
create function public.pitch_json(p_pitch uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', p.id, 'venue', v.name, 'venue_ar', coalesce(v.name_ar, v.name),
    'district', v.district, 'km', 0,
    'rating', coalesce((select round(avg(r.stars), 1) from public.pitch_ratings r
                        where r.pitch_id = p.id), 0),
    'reviews', (select count(*) from public.pitch_ratings r where r.pitch_id = p.id),
    'max_per_side', p.max_per_side, 'price_da', p.price_da,
    'features', to_jsonb(p.features), 'active', p.active)
  from public.pitches p join public.venues v on v.id = p.venue_id
  where p.id = p_pitch;
$$;

create function public.list_pitches(p_query text default '')
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.pitch_json(p.id)
  from public.pitches p join public.venues v on v.id = p.venue_id
  where p.active
    and (coalesce(p_query, '') = ''
         or (v.name || ' ' || coalesce(v.name_ar, '') || ' ' || v.district || ' ' || p.name)
            ilike '%' || p_query || '%')
  order by v.name, p.name
  limit 100;
$$;

-- Players looking for a game right now (home counter). A number only.
create function public.live_searching()
returns integer
language sql
stable
security definer
set search_path = ''
as $$
  select count(*)::integer from public.match_requests where status = 'searching';
$$;

-- ── Players and friends ─────────────────────────────────────────────────
-- Public view of a player, with my friendship status.
create function public.player_json(p_user uuid)
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

create function public.find_players(p_query text)
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.player_json(p.id) from public.profiles p
  where length(trim(coalesce(p_query, ''))) >= 2
    and p.id <> (select auth.uid())
    and (p.handle ilike '%' || ltrim(trim(p_query), '@') || '%'
         or p.full_name ilike '%' || trim(p_query) || '%')
    and not exists (select 1 from public.blocked_users b
                    where b.blocker_id = p.id and b.blocked_id = (select auth.uid()))
  order by p.handle
  limit 20;
$$;

create function public.get_player(p_handle text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  u uuid;
begin
  select id into u from public.profiles where handle = lower(p_handle);
  if u is null then
    raise exception 'player not found' using errcode = 'P0002';
  end if;
  return public.player_json(u);
end;
$$;

-- Friends, requests I got and requests I sent.
create function public.my_friends()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.player_json(case when f.requester_id = (select auth.uid())
                                 then f.addressee_id else f.requester_id end)
  from public.friendships f
  where (select auth.uid()) in (f.requester_id, f.addressee_id);
$$;

create function public.my_blocked()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.player_json(b.blocked_id) from public.blocked_users b
  where b.blocker_id = (select auth.uid());
$$;

-- Handle → id for the actions that take a handle (friends, teams, block).
create function public.user_id_of(p_handle text)
returns uuid
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  u uuid;
begin
  select id into u from public.profiles where handle = lower(ltrim(p_handle, '@'));
  if u is null then
    raise exception 'player not found' using errcode = 'P0002';
  end if;
  return u;
end;
$$;

-- ── Teams ───────────────────────────────────────────────────────────────
create function public.team_json(p_team uuid)
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select jsonb_build_object(
    'id', t.id, 'name', t.name, 'per_side', t.per_side,
    'captain_handle', (select handle from public.profiles where id = t.captain_id),
    'i_am_captain', t.captain_id = (select auth.uid()),
    'usual_weekday', t.usual_weekday, 'usual_hour', t.usual_hour,
    'usual_pitch_id', t.usual_pitch_id,
    'members', coalesce((select jsonb_agg(public.player_json(m.user_id))
                         from public.team_members m where m.team_id = t.id), '[]'::jsonb))
  from public.teams t where t.id = p_team;
$$;

create function public.my_teams()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.team_json(t.id) from public.teams t
  where t.captain_id = (select auth.uid())
     or exists (select 1 from public.team_members m
                where m.team_id = t.id and m.user_id = (select auth.uid()))
  order by t.created_at;
$$;

-- ── My profile, with stats ──────────────────────────────────────────────
create function public.my_stats()
returns table (played integer, wins integer, goals integer, reliability integer)
language sql
stable
security definer
set search_path = ''
as $$
  select
    (select count(*)::integer from public.game_players where user_id = (select auth.uid()) and attended),
    (select count(*)::integer from public.wallet_ledger where user_id = (select auth.uid()) and reason = 'win'),
    (select count(*)::integer from public.match_events where player_id = (select auth.uid()) and type = 'goal'),
    public.reliability_of((select auth.uid()));
$$;

revoke all on function public.pitch_json(uuid), public.player_json(uuid),
  public.team_json(uuid) from public, anon, authenticated;
revoke all on function public.list_pitches(text), public.live_searching(),
  public.find_players(text), public.get_player(text), public.my_friends(),
  public.my_blocked(), public.user_id_of(text), public.my_teams(), public.my_stats()
  from public, anon;
grant execute on function public.list_pitches(text), public.live_searching(),
  public.find_players(text), public.get_player(text), public.my_friends(),
  public.my_blocked(), public.user_id_of(text), public.my_teams(), public.my_stats()
  to authenticated, service_role;
