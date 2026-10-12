-- Manager reports (bookings, cash expected vs received, occupancy) and
-- staff (other managers of the same venue). Managers of that venue only.

create function public.venue_report(p_venue uuid, p_from timestamptz, p_to timestamptz)
returns table (
  bookings integer, requested integer, confirmed integer, guaranteed integer,
  completed integer, cancelled integer, no_shows integer, walk_ins integer,
  cash_expected_da integer, cash_received_da integer,
  booked_hours integer, open_hours integer
)
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  days integer;
begin
  if not public.is_venue_manager(p_venue) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  if p_to <= p_from or p_to - p_from > interval '93 days' then
    raise exception 'range must be 93 days or less' using errcode = '22023';
  end if;
  days := greatest(1, ceil(extract(epoch from p_to - p_from) / 86400)::integer);
  return query
  with b as (
    select bk.* from public.bookings bk
    join public.pitches p on p.id = bk.pitch_id
    where p.venue_id = p_venue and bk.starts_at >= p_from and bk.starts_at < p_to
  ), w as (
    select pb.* from public.pitch_blocks pb
    join public.pitches p on p.id = pb.pitch_id
    where p.venue_id = p_venue and pb.kind = 'walk_in'
      and pb.starts_at >= p_from and pb.starts_at < p_to
  )
  select
    (select count(*)::integer from b),
    (select count(*)::integer from b where status = 'requested'),
    (select count(*)::integer from b where status = 'confirmed'),
    (select count(*)::integer from b where status = 'guaranteed'),
    (select count(*)::integer from b where status = 'completed'),
    (select count(*)::integer from b where status = 'cancelled'),
    (select count(*)::integer from b where status = 'no_show'),
    (select count(*)::integer from w),
    (select coalesce(sum(total_da), 0)::integer from b
      where payment_method = 'cash' and status in ('confirmed', 'guaranteed', 'completed')),
    (select coalesce(sum(total_da), 0)::integer from b
      where payment_method = 'cash' and status in ('guaranteed', 'completed')),
    ((select coalesce(sum(extract(epoch from ends_at - starts_at)), 0) from b
       where status not in ('cancelled', 'no_show'))
     + (select coalesce(sum(extract(epoch from ends_at - starts_at)), 0) from w))::integer / 3600,
    (select (v.close_hour - v.open_hour) * days
            * (select count(*) from public.pitches p where p.venue_id = p_venue and p.active)
     from public.venues v where v.id = p_venue)::integer;
end;
$$;

-- Managers of my venue. Handles and names only.
create function public.venue_staff(p_venue uuid)
returns table (handle text, full_name text, is_me boolean)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.is_venue_manager(p_venue) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  return query
    select p.handle, p.full_name, vm.user_id = (select auth.uid())
    from public.venue_managers vm join public.profiles p on p.id = vm.user_id
    where vm.venue_id = p_venue
    order by p.full_name;
end;
$$;

-- Add a verified player as manager of my venue.
create function public.add_venue_manager(p_venue uuid, p_handle text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  target uuid;
begin
  if not public.is_venue_manager(p_venue) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  select id into target from public.profiles
  where handle = lower(p_handle) and verified_at is not null;
  if target is null then
    raise exception 'no verified player with that handle' using errcode = 'P0002';
  end if;
  insert into public.venue_managers (venue_id, user_id) values (p_venue, target)
  on conflict do nothing;
end;
$$;

-- Remove a manager; a venue always keeps at least one.
create function public.remove_venue_manager(p_venue uuid, p_handle text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not public.is_venue_manager(p_venue) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  if (select count(*) from public.venue_managers where venue_id = p_venue) <= 1 then
    raise exception 'a venue needs at least one manager' using errcode = '22023';
  end if;
  delete from public.venue_managers vm
  using public.profiles p
  where vm.venue_id = p_venue and vm.user_id = p.id and p.handle = lower(p_handle);
end;
$$;

revoke all on function public.venue_report(uuid, timestamptz, timestamptz),
  public.venue_staff(uuid), public.add_venue_manager(uuid, text),
  public.remove_venue_manager(uuid, text) from public, anon;
grant execute on function public.venue_report(uuid, timestamptz, timestamptz),
  public.venue_staff(uuid), public.add_venue_manager(uuid, text),
  public.remove_venue_manager(uuid, text) to authenticated, service_role;
