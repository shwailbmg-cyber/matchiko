-- Bookings must fit the venue's opening hours (Algiers time). Checked on
-- every insert, so request_booking and any future path obey it.
create function public.bookings_hours_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v public.venues;
  start_h numeric;
  end_h numeric;
begin
  select v2.* into v
  from public.pitches p join public.venues v2 on v2.id = p.venue_id
  where p.id = new.pitch_id;
  if v.open_hour = 0 and v.close_hour = 24 then
    return new;  -- open all day, games may cross midnight
  end if;
  start_h := extract(epoch from (new.starts_at at time zone 'Africa/Algiers')::time) / 3600;
  end_h := start_h + extract(epoch from new.ends_at - new.starts_at) / 3600;
  if start_h < v.open_hour or end_h > v.close_hour then
    raise exception 'venue closed at that time' using errcode = '22023';
  end if;
  return new;
end;
$$;

revoke all on function public.bookings_hours_guard() from public, anon, authenticated;

create trigger bookings_hours_guard before insert on public.bookings
  for each row execute function public.bookings_hours_guard();
