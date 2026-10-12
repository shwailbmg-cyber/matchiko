-- Manager reads a booking from its QR token before taking the cash.
-- Same rule as scan_booking_qr: only bookings at a venue the caller manages.
create function public.booking_by_qr(p_token text)
returns jsonb
language plpgsql
stable
security definer
set search_path = ''
as $$
declare
  v_game uuid;
  v_booking uuid;
begin
  select t.booking_id, g.id into v_booking, v_game
  from public.booking_tickets t
  join public.games g on g.booking_id = t.booking_id
  where t.qr_token = p_token;
  if not found or not public.manages_booking(v_booking) then
    raise exception 'unknown ticket' using errcode = 'P0002';
  end if;
  return public.game_json(v_game);
end;
$$;

revoke all on function public.booking_by_qr(text) from public, anon;
grant execute on function public.booking_by_qr(text) to authenticated;
