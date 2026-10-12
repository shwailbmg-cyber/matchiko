-- Server matchmaking v1 (ARCHITECTURE.md §6): the best open game for the
-- caller right now. Scores: position fit 40 + time fit 20 + level 15 +
-- friend in the game 5 (no distance yet: same wilaya only).
-- Never offers a game with someone the caller blocked or who blocked them.
-- Joining still goes through join_open_game, which re-checks everything.
create function public.find_match(p_positions public.position[])
returns jsonb
language sql
stable
security definer
set search_path = ''
as $$
  with me as (
    select p.id, p.city_id,
      array_position(array['beginner','casual','good','competitive'], p.level) as lvl
    from public.profiles p where p.id = (select auth.uid())
  ),
  candidates as (
    select g.id, b.starts_at,
      (select count(*) from public.game_players gp where gp.game_id = g.id
         and gp.position = 'gk') as keepers,
      (select avg(array_position(array['beginner','casual','good','competitive'], pr.level))
         from public.game_players gp join public.profiles pr on pr.id = gp.user_id
         where gp.game_id = g.id) as avg_lvl,
      exists (select 1 from public.game_players gp
              join public.friendships f on f.status = 'accepted'
                and ((f.requester_id = me.id and f.addressee_id = gp.user_id)
                  or (f.addressee_id = me.id and f.requester_id = gp.user_id))
              where gp.game_id = g.id) as friend
    from me, public.games g
    join public.bookings b on b.id = g.booking_id
    join public.pitches p on p.id = b.pitch_id
    join public.venues v on v.id = p.venue_id
    where g.is_open
      and b.starts_at > now() and b.starts_at < now() + interval '7 days'
      and b.status in ('requested', 'confirmed', 'guaranteed')
      and (me.city_id is null or v.city_id = me.city_id)
      and b.booker_id <> me.id
      and not exists (select 1 from public.game_players gp
                      where gp.game_id = g.id and gp.user_id = me.id)
      and (select count(*) from public.game_players gp where gp.game_id = g.id) < g.per_side * 2
      and not exists (select 1 from public.game_players gp
                      join public.blocked_users bu
                        on (bu.blocker_id = me.id and bu.blocked_id = gp.user_id)
                        or (bu.blocked_id = me.id and bu.blocker_id = gp.user_id)
                      where gp.game_id = g.id)
  ),
  scored as (
    select c.id,
      -- First wanted position that still has room (2 keepers per game).
      coalesce((select 40 - 10 * (i - 1)
                from generate_subscripts(p_positions, 1) i
                where p_positions[i] <> 'gk' or c.keepers < 2
                order by i limit 1), 0)
      + 20 * greatest(0, 1 - extract(epoch from c.starts_at - now()) / (7 * 86400))
      + case when me.lvl is null or c.avg_lvl is null then 7.5
             else 15 * (1 - abs(me.lvl - c.avg_lvl) / 3) end
      + case when c.friend then 5 else 0 end as score,
      c.starts_at
    from candidates c, me
  )
  select public.game_json(s.id)
  from scored s
  order by s.score desc, s.starts_at
  limit 1;
$$;

revoke all on function public.find_match(public.position[]) from public, anon;
grant execute on function public.find_match(public.position[]) to authenticated;
