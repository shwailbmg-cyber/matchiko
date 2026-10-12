-- Read API for the manager and referee screens: today's games, the week
-- calendar, verification queue, referee requests, open reports, my
-- referee jobs. Managers see their own venues only.

-- Games at my venues today (local Algeria time).
create function public.venue_today()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.game_json(g.id)
  from public.games g
  join public.bookings b on b.id = g.booking_id
  where public.manages_booking(b.id)
    and (b.starts_at at time zone 'Africa/Algiers')::date
        = (now() at time zone 'Africa/Algiers')::date
    and b.status <> 'cancelled'
  order by b.starts_at;
$$;

-- Bookings, blocks and walk-ins on one of my pitches for 7 days.
create function public.venue_week(p_pitch uuid, p_from timestamptz)
returns table (
  id text, starts_at timestamptz, kind text, label text, phone text,
  status text, game_id uuid
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_venue_manager((select venue_id from public.pitches where pitches.id = p_pitch)) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  return query
    select b.id::text, b.starts_at, 'booking'::text,
      coalesce((select full_name from public.profiles where profiles.id = b.booker_id), ''),
      null::text, b.status::text, g.id
    from public.bookings b left join public.games g on g.booking_id = b.id
    where b.pitch_id = p_pitch and b.status not in ('cancelled')
      and b.starts_at >= p_from and b.starts_at < p_from + interval '7 days'
    union all
    select pb.id::text, pb.starts_at,
      case pb.kind when 'walk_in' then 'walkIn' else 'blocked' end,
      pb.label, pb.phone, null::text, null::uuid
    from public.pitch_blocks pb
    where pb.pitch_id = p_pitch
      and pb.starts_at >= p_from and pb.starts_at < p_from + interval '7 days'
    order by 2;
end;
$$;

-- Players who asked to be verified at one of my venues (public fields).
create function public.verification_queue()
returns setof jsonb
language sql
stable
security definer
set search_path = ''
as $$
  select public.player_json(v.user_id)
  from public.verification_requests v
  join public.profiles p on p.id = v.user_id
  where public.is_venue_manager(v.venue_id) and p.verified_at is null
  order by v.created_at;
$$;

create function public.venue_referee_applications()
returns table (id uuid, player jsonb)
language sql
stable
security definer
set search_path = ''
as $$
  select a.id, public.player_json(a.user_id)
  from public.referee_applications a
  where a.status = 'pending' and public.is_venue_manager(a.venue_id)
  order by a.created_at;
$$;

-- Open reports about games at my venues.
create function public.venue_open_reports()
returns table (
  id bigint, reporter_name text, reported jsonb, reason text, note text,
  game_starts_at timestamptz
)
language sql
stable
security definer
set search_path = ''
as $$
  select r.id, rp.full_name, public.player_json(r.reported_id), r.reason::text,
    r.note, b.starts_at
  from public.player_reports r
  join public.games g on g.id = r.game_id
  join public.bookings b on b.id = g.booking_id
  join public.profiles rp on rp.id = r.reporter_id
  where r.status = 'open' and public.manages_booking(b.id)
  order by r.created_at;
$$;

-- Games I referee (upcoming and past), with whether the report is in.
create function public.my_referee_jobs()
returns table (
  booking_id uuid, starts_at timestamptz, venue_name text, per_side smallint,
  game_id uuid, reported boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select b.id, b.starts_at, v.name, g.per_side, g.id,
    exists (select 1 from public.match_events e where e.game_id = g.id)
  from public.bookings b
  join public.pitches p on p.id = b.pitch_id
  join public.venues v on v.id = p.venue_id
  left join public.games g on g.booking_id = b.id
  where b.referee_id = (select auth.uid()) and b.status <> 'cancelled'
  order by b.starts_at desc
  limit 50;
$$;

revoke all on function public.venue_today(), public.venue_week(uuid, timestamptz),
  public.verification_queue(), public.venue_referee_applications(),
  public.venue_open_reports(), public.my_referee_jobs() from public, anon;
grant execute on function public.venue_today(), public.venue_week(uuid, timestamptz),
  public.verification_queue(), public.venue_referee_applications(),
  public.venue_open_reports(), public.my_referee_jobs() to authenticated, service_role;
