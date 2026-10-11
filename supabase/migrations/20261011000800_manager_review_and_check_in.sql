-- Manager tools: review player reports about games at their venue
-- (accepting a no-show applies the usual penalty once), and check players
-- in when they arrive.

alter table public.player_reports
  add column status text not null default 'open'
    check (status in ('open', 'accepted', 'rejected')),
  add column reviewed_by uuid references auth.users (id),
  add column reviewed_at timestamptz;

-- Managers see reports about games played at their venue.
create policy player_reports_manager_select on public.player_reports
  for select to authenticated
  using (
    game_id is not null
    and exists (select 1 from public.games g
                where g.id = game_id and public.manages_booking(g.booking_id))
  );

create function public.review_player_report(p_report bigint, p_accept boolean)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.player_reports;
begin
  select * into r from public.player_reports where id = p_report for update;
  if not found or r.game_id is null or not exists (
    select 1 from public.games g
    where g.id = r.game_id and public.manages_booking(g.booking_id)
  ) then
    raise exception 'report not found' using errcode = 'P0002';
  end if;
  if r.status <> 'open' then
    raise exception 'report already reviewed' using errcode = '22023';
  end if;
  update public.player_reports
  set status = case when p_accept then 'accepted' else 'rejected' end,
      reviewed_by = (select auth.uid()), reviewed_at = now()
  where id = p_report;
  if p_accept and r.reason = 'no_show' then
    perform public.apply_no_show(r.reported_id, r.game_id);
  end if;
end;
$$;

-- Manager marks a player as arrived (by @handle, from their QR).
create function public.check_in_player(p_game uuid, p_handle text)
returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  if not exists (select 1 from public.games g
                 where g.id = p_game and public.manages_booking(g.booking_id)) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  update public.game_players gp set attended = true
  from public.profiles p
  where gp.game_id = p_game and gp.user_id = p.id and p.handle = p_handle;
  if not found then
    raise exception 'player not in this game' using errcode = 'P0002';
  end if;
end;
$$;

revoke all on function public.review_player_report(bigint, boolean),
  public.check_in_player(uuid, text) from public, anon;
grant execute on function public.review_player_report(bigint, boolean),
  public.check_in_player(uuid, text) to authenticated, service_role;
