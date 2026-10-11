-- Referee availability and job board. Approved referees (public.referees)
-- see upcoming bookings that asked for a referee and take one. The fee
-- (200 DA) is paid in cash by the booker; XP/coins come from
-- submit_match_report.

create table public.referee_availability (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  weekday smallint not null check (weekday between 1 and 7), -- ISO, 1 = Monday
  start_hour smallint not null check (start_hour between 6 and 23),
  end_hour smallint not null check (end_hour between 7 and 24),
  primary key (user_id, weekday),
  check (end_hour > start_hour)
);

alter table public.referee_availability enable row level security;

revoke all on public.referee_availability from public, anon, authenticated;
grant select, delete on public.referee_availability to authenticated;
grant insert (weekday, start_hour, end_hour) on public.referee_availability to authenticated;
grant update (start_hour, end_hour) on public.referee_availability to authenticated;

create policy referee_availability_select on public.referee_availability
  for select to authenticated using (user_id = (select auth.uid()));
create policy referee_availability_insert on public.referee_availability
  for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (select 1 from public.referees r where r.user_id = (select auth.uid()))
  );
create policy referee_availability_update on public.referee_availability
  for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy referee_availability_delete on public.referee_availability
  for delete to authenticated using (user_id = (select auth.uid()));

-- Upcoming games that asked for a referee and have none yet.
create function public.open_referee_jobs()
returns table (
  booking_id uuid, starts_at timestamptz, venue_name text, pitch_name text,
  city_id text, per_side smallint
)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.referees where user_id = (select auth.uid())) then
    raise exception 'referees only' using errcode = '42501';
  end if;
  return query
    select b.id, b.starts_at, v.name, p.name, v.city_id, g.per_side
    from public.bookings b
    join public.pitches p on p.id = b.pitch_id
    join public.venues v on v.id = p.venue_id
    left join public.games g on g.booking_id = b.id
    where b.with_referee and b.referee_id is null
      and b.status in ('requested', 'confirmed', 'guaranteed')
      and b.starts_at > now()
      and b.booker_id <> (select auth.uid())
    order by b.starts_at
    limit 50;
end;
$$;

-- Take a job: one referee per game, no overlap with my other jobs.
create function public.take_referee_job(p_booking uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
  b public.bookings;
begin
  if not exists (select 1 from public.referees where user_id = me) then
    raise exception 'referees only' using errcode = '42501';
  end if;
  select * into b from public.bookings where id = p_booking for update;
  if not found or not b.with_referee or b.referee_id is not null
     or b.status not in ('requested', 'confirmed', 'guaranteed')
     or b.starts_at <= now() or b.booker_id = me then
    raise exception 'job not available' using errcode = 'P0002';
  end if;
  if exists (select 1 from public.bookings o
             where o.referee_id = me and o.status not in ('cancelled', 'no_show')
               and tstzrange(o.starts_at, o.ends_at) && tstzrange(b.starts_at, b.ends_at)) then
    raise exception 'you already referee a game at that time' using errcode = '22023';
  end if;
  update public.bookings set referee_id = me where id = p_booking;
end;
$$;

revoke all on function public.open_referee_jobs(), public.take_referee_job(uuid)
  from public, anon;
grant execute on function public.open_referee_jobs(), public.take_referee_job(uuid)
  to authenticated, service_role;
