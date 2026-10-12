-- The server writes the inbox (notifications); a Database Webhook on
-- notifications INSERT calls the `push` Edge Function, which sends to the
-- user's devices (push_tokens). Payload values are display text only.

-- ── Device tokens ───────────────────────────────────────────────────────
create table public.push_tokens (
  token text primary key check (length(token) between 20 and 4096),
  user_id uuid not null references auth.users (id) on delete cascade,
  platform text not null check (platform in ('android', 'ios', 'web')),
  updated_at timestamptz not null default now()
);
create index push_tokens_user_idx on public.push_tokens (user_id);
alter table public.push_tokens enable row level security;
revoke all on public.push_tokens from public, anon, authenticated;
grant select on public.push_tokens to authenticated;
create policy "own push tokens" on public.push_tokens
  for select to authenticated using (user_id = (select auth.uid()));

-- A token belongs to the last account that signed in on the device.
create function public.register_push_token(p_token text, p_platform text)
returns void
language sql
security definer
set search_path = ''
as $$
  insert into public.push_tokens (token, user_id, platform)
  values (p_token, (select auth.uid()), p_platform)
  on conflict (token) do update
    set user_id = excluded.user_id, platform = excluded.platform, updated_at = now();
$$;

create function public.unregister_push_token(p_token text)
returns void
language sql
security definer
set search_path = ''
as $$
  delete from public.push_tokens
  where token = p_token and user_id = (select auth.uid());
$$;

revoke all on function public.register_push_token(text, text),
  public.unregister_push_token(text) from public, anon;
grant execute on function public.register_push_token(text, text),
  public.unregister_push_token(text) to authenticated;

-- ── Inbox writers ───────────────────────────────────────────────────────
create function public.hhmm(p_at timestamptz)
returns text
language sql
immutable
set search_path = ''
as $$ select to_char(p_at at time zone 'Africa/Algiers', 'HH24:MI') $$;

-- Booking confirmed → booker. Booking completed → every player rates it.
create function public.notify_booking_status()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_game uuid := (select g.id from public.games g where g.booking_id = new.id);
begin
  if new.status = 'confirmed' and old.status = 'requested' then
    insert into public.notifications (user_id, kind, payload)
    values (new.booker_id, 'booking_confirmed',
            jsonb_build_object('game_id', v_game, 'time', public.hhmm(new.starts_at)));
  elsif new.status = 'completed' and old.status <> 'completed' then
    insert into public.notifications (user_id, kind, payload)
    select gp.user_id, 'rate_game', jsonb_build_object('game_id', v_game)
    from public.game_players gp where gp.game_id = v_game;
  end if;
  return null;
end;
$$;
create trigger bookings_notify after update of status on public.bookings
  for each row execute function public.notify_booking_status();

create function public.notify_friend_request()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.status = 'pending' then
    insert into public.notifications (user_id, kind, payload)
    select new.addressee_id, 'friend_request',
           jsonb_build_object('handle', p.handle, 'name', p.full_name)
    from public.profiles p where p.id = new.requester_id;
  end if;
  return null;
end;
$$;
create trigger friendships_notify after insert on public.friendships
  for each row execute function public.notify_friend_request();

-- A game opens → the booker's friends who want "spots near you", unless
-- they block each other or already play in it.
create function public.notify_game_opened()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if new.is_open and not old.is_open then
    insert into public.notifications (user_id, kind, payload)
    select pr.id, 'spot_open',
           jsonb_build_object('game_id', new.id, 'pitch', v.name,
                              'time', public.hhmm(b.starts_at))
    from public.bookings b
    join public.pitches p on p.id = b.pitch_id
    join public.venues v on v.id = p.venue_id
    join public.friendships f on f.status = 'accepted'
      and b.booker_id in (f.requester_id, f.addressee_id)
    join public.profiles pr on pr.id = case when f.requester_id = b.booker_id
                                            then f.addressee_id else f.requester_id end
    where b.id = new.booking_id and b.starts_at > now()
      and pr.notify_nearby
      and not exists (select 1 from public.game_players gp
                      where gp.game_id = new.id and gp.user_id = pr.id)
      and not exists (select 1 from public.blocked_users bu
                      where (bu.blocker_id = pr.id and bu.blocked_id = b.booker_id)
                         or (bu.blocked_id = pr.id and bu.blocker_id = b.booker_id));
  end if;
  return null;
end;
$$;
create trigger games_notify_open after update of is_open on public.games
  for each row execute function public.notify_game_opened();

-- "Still coming?" about 2–3 hours before kick-off, once per player and
-- game. Runs every 15 minutes (pg_cron on Supabase).
create function public.send_reminders()
returns integer
language plpgsql
security definer
set search_path = ''
as $$
declare
  n integer;
begin
  insert into public.notifications (user_id, kind, payload)
  select gp.user_id, 'still_coming',
         jsonb_build_object('game_id', g.id, 'time', public.hhmm(b.starts_at))
  from public.bookings b
  join public.games g on g.booking_id = b.id
  join public.game_players gp on gp.game_id = g.id
  join public.profiles pr on pr.id = gp.user_id
  where b.status in ('confirmed', 'guaranteed')
    and b.starts_at between now() + interval '2 hours' and now() + interval '3 hours'
    and pr.notify_reminders
    and not exists (select 1 from public.notifications n
                    where n.user_id = gp.user_id and n.kind = 'still_coming'
                      and n.payload ->> 'game_id' = g.id::text);
  get diagnostics n = row_count;
  return n;
end;
$$;

revoke all on function public.hhmm(timestamptz), public.notify_booking_status(),
  public.notify_friend_request(), public.notify_game_opened(),
  public.send_reminders() from public, anon, authenticated;

do $$
begin
  if exists (select 1 from pg_extension where extname = 'pg_cron') then
    perform cron.schedule('send-reminders', '*/15 * * * *',
                          'select public.send_reminders()');
  end if;
end;
$$;
