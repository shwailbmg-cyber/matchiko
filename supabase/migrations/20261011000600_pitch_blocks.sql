-- Manager calendar: blocked slots (maintenance, private event) and walk-in
-- bookings typed in by the manager for customers without the app. Both
-- take the slot like a booking: triggers keep bookings and blocks from
-- overlapping. Players see busy hours through pitch_busy(), never who.

create type public.block_kind as enum ('blocked', 'walk_in');

create table public.pitch_blocks (
  id uuid primary key default gen_random_uuid(),
  pitch_id uuid not null references public.pitches (id) on delete cascade,
  starts_at timestamptz not null,
  ends_at timestamptz not null,
  during tstzrange generated always as (tstzrange(starts_at, ends_at, '[)')) stored,
  kind public.block_kind not null,
  -- Reason, or the walk-in customer's name.
  label text not null default '' check (char_length(label) <= 60),
  phone text check (phone is null or phone ~ '^\+213[567][0-9]{8}$'),
  created_by uuid not null default auth.uid() references auth.users (id),
  created_at timestamptz not null default now(),
  check (ends_at > starts_at),
  exclude using gist (pitch_id with =, during with &&)
);
create index pitch_blocks_pitch_idx on public.pitch_blocks (pitch_id, starts_at);

alter table public.pitch_blocks enable row level security;

revoke all on public.pitch_blocks from public, anon, authenticated;
grant select, delete on public.pitch_blocks to authenticated;
grant insert (pitch_id, starts_at, ends_at, kind, label, phone)
  on public.pitch_blocks to authenticated;

create policy pitch_blocks_select on public.pitch_blocks
  for select to authenticated
  using (public.is_venue_manager((select venue_id from public.pitches p where p.id = pitch_id)));
create policy pitch_blocks_insert on public.pitch_blocks
  for insert to authenticated
  with check (
    created_by = (select auth.uid())
    and public.is_venue_manager((select venue_id from public.pitches p where p.id = pitch_id))
  );
create policy pitch_blocks_delete on public.pitch_blocks
  for delete to authenticated
  using (public.is_venue_manager((select venue_id from public.pitches p where p.id = pitch_id)));

-- A booking cannot take a blocked slot, and a block cannot cover a live booking.
-- (Generated columns are not computed yet in BEFORE triggers: build the range.)
create function public.bookings_block_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status not in ('cancelled', 'no_show') and exists (
    select 1 from public.pitch_blocks pb
    where pb.pitch_id = new.pitch_id
      and pb.during && tstzrange(new.starts_at, new.ends_at, '[)')
  ) then
    raise exception 'slot not available' using errcode = '23P01';
  end if;
  return new;
end;
$$;

create trigger bookings_block_guard
  before insert or update of starts_at, ends_at, pitch_id on public.bookings
  for each row execute function public.bookings_block_guard();

create function public.pitch_blocks_booking_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (
    select 1 from public.bookings b
    where b.pitch_id = new.pitch_id
      and b.during && tstzrange(new.starts_at, new.ends_at, '[)')
      and b.status not in ('cancelled', 'no_show')
  ) then
    raise exception 'slot already booked' using errcode = '23P01';
  end if;
  return new;
end;
$$;

create trigger pitch_blocks_booking_guard
  before insert on public.pitch_blocks
  for each row execute function public.pitch_blocks_booking_guard();

-- Busy hours on a pitch (at most 8 days), for the slot grid. No names.
create function public.pitch_busy(p_pitch uuid, p_from timestamptz, p_to timestamptz)
returns table (starts_at timestamptz, ends_at timestamptz, pending boolean)
language plpgsql
stable
security definer
set search_path = ''
as $$
begin
  if p_to <= p_from or p_to - p_from > interval '8 days' then
    raise exception 'range must be 8 days or less' using errcode = '22023';
  end if;
  return query
    select b.starts_at, b.ends_at, b.status = 'requested'
    from public.bookings b
    where b.pitch_id = p_pitch and b.status not in ('cancelled', 'no_show')
      and b.during && tstzrange(p_from, p_to)
    union all
    select pb.starts_at, pb.ends_at, false
    from public.pitch_blocks pb
    where pb.pitch_id = p_pitch and pb.during && tstzrange(p_from, p_to)
    order by 1;
end;
$$;

revoke all on function public.bookings_block_guard(), public.pitch_blocks_booking_guard(),
  public.pitch_busy(uuid, timestamptz, timestamptz) from public, anon, authenticated;
grant execute on function public.pitch_busy(uuid, timestamptz, timestamptz)
  to authenticated, service_role;
