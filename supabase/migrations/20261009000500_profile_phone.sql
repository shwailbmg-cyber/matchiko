-- Phone number lives on the profile (sign-in is Google or email code, no SMS
-- at launch). Private: only the owner (get_my_profile) and the manager of a
-- venue where they booked (booking_contact) can read it. The manager checks
-- it in person at verification and calls it to confirm bookings.

alter table public.profiles
  add column phone text check (phone is null or phone ~ '^\+213[567][0-9]{8}$');

grant update (phone) on public.profiles to authenticated;

drop function public.get_my_profile();
create function public.get_my_profile()
returns table (
  id uuid, handle text, full_name text, avatar_url text, city_id text,
  positions public.position[], lang text, phone text, verified_at timestamptz,
  xp integer, rank text, coins integer, no_show_count integer,
  booking_ban_until timestamptz, is_referee boolean
)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.handle, p.full_name, p.avatar_url, p.city_id, p.positions, p.lang,
    p.phone, p.verified_at, p.xp, public.rank_of(p.xp), p.coins, p.no_show_count,
    p.booking_ban_until,
    exists (select 1 from public.referees r where r.user_id = p.id)
  from public.profiles p
  where p.id = (select auth.uid());
$$;

-- Who to call about a booking. Managers of that booking's venue only.
create function public.booking_contact(p_booking uuid)
returns table (handle text, full_name text, phone text)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not public.manages_booking(p_booking) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  return query
    select p.handle, p.full_name, p.phone
    from public.bookings b join public.profiles p on p.id = b.booker_id
    where b.id = p_booking;
end;
$$;

revoke all on function public.get_my_profile(), public.booking_contact(uuid)
  from public, anon;
grant execute on function public.get_my_profile(), public.booking_contact(uuid)
  to authenticated, service_role;
