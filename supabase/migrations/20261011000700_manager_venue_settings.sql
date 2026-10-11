-- Managers edit their own venue (opening hours) and pitches (price, size,
-- amenities, active). Prices stay server data: request_booking reads them.

alter table public.venues
  add column open_hour smallint not null default 8 check (open_hour between 0 and 23),
  add column close_hour smallint not null default 24 check (close_hour between 1 and 24),
  add constraint venues_hours_check check (close_hour > open_hour);

grant update (open_hour, close_hour) on public.venues to authenticated;
grant update (name, price_da, max_per_side, features, active) on public.pitches to authenticated;

create policy "managers edit their venue" on public.venues
  for update to authenticated
  using (public.is_venue_manager(id))
  with check (public.is_venue_manager(id));

create policy "managers edit their pitches" on public.pitches
  for update to authenticated
  using (public.is_venue_manager(venue_id))
  with check (public.is_venue_manager(venue_id));
