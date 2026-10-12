-- Settings: notification choices and who sees my games, blocked players,
-- "report a problem" messages, and deleting my account.

alter table public.profiles
  add column notify_nearby boolean not null default true,
  add column notify_reminders boolean not null default true,
  add column games_visibility text not null default 'friends'
    check (games_visibility in ('everyone', 'friends', 'nobody'));

grant update (notify_nearby, notify_reminders, games_visibility)
  on public.profiles to authenticated;

-- Private settings come back through get_my_settings(), not the
-- public profile columns.
create function public.get_my_settings()
returns table (notify_nearby boolean, notify_reminders boolean, games_visibility text)
language sql
stable
security definer
set search_path = ''
as $$
  select p.notify_nearby, p.notify_reminders, p.games_visibility
  from public.profiles p where p.id = (select auth.uid());
$$;

-- ── Blocked players ─────────────────────────────────────────────────────
create table public.blocked_users (
  blocker_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  blocked_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);

alter table public.blocked_users enable row level security;
revoke all on public.blocked_users from public, anon, authenticated;
grant select, delete on public.blocked_users to authenticated;
grant insert (blocked_id) on public.blocked_users to authenticated;

create policy blocked_users_select on public.blocked_users
  for select to authenticated using (blocker_id = (select auth.uid()));
create policy blocked_users_insert on public.blocked_users
  for insert to authenticated with check (blocker_id = (select auth.uid()));
create policy blocked_users_delete on public.blocked_users
  for delete to authenticated using (blocker_id = (select auth.uid()));

-- No friend requests between blocked players (either way); blocking also
-- removes an existing friendship.
create function public.friendships_block_guard()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if exists (
    select 1 from public.blocked_users b
    where (b.blocker_id = new.requester_id and b.blocked_id = new.addressee_id)
       or (b.blocker_id = new.addressee_id and b.blocked_id = new.requester_id)
  ) then
    raise exception 'not allowed' using errcode = '42501';
  end if;
  return new;
end;
$$;
create trigger friendships_block_guard
  before insert on public.friendships
  for each row execute function public.friendships_block_guard();

create function public.blocked_users_unfriend()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.friendships f
  where (f.requester_id = new.blocker_id and f.addressee_id = new.blocked_id)
     or (f.requester_id = new.blocked_id and f.addressee_id = new.blocker_id);
  return new;
end;
$$;
create trigger blocked_users_unfriend
  after insert on public.blocked_users
  for each row execute function public.blocked_users_unfriend();

-- ── Report a problem ────────────────────────────────────────────────────
create table public.support_messages (
  id bigint generated always as identity primary key,
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  message text not null check (char_length(message) between 5 and 2000),
  created_at timestamptz not null default now()
);

alter table public.support_messages enable row level security;
revoke all on public.support_messages from public, anon, authenticated;
grant select on public.support_messages to authenticated;
grant insert (message) on public.support_messages to authenticated;

create policy support_messages_select on public.support_messages
  for select to authenticated using (user_id = (select auth.uid()));
create policy support_messages_insert on public.support_messages
  for insert to authenticated with check (user_id = (select auth.uid()));

-- ── Delete my account (required by Google Play and the App Store) ──────
-- Refused while the player has an upcoming paid or confirmed booking, or
-- is the only manager of a venue: those need handing over first.
create function public.delete_my_account()
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  me uuid := (select auth.uid());
begin
  if me is null then
    raise exception 'not signed in' using errcode = '42501';
  end if;
  if exists (select 1 from public.bookings
             where booker_id = me and starts_at > now()
               and status in ('confirmed', 'guaranteed')) then
    raise exception 'cancel your upcoming bookings first' using errcode = '22023';
  end if;
  if exists (select 1 from public.venue_managers vm
             where vm.user_id = me
               and (select count(*) from public.venue_managers o
                    where o.venue_id = vm.venue_id) = 1) then
    raise exception 'add another manager to your venue first' using errcode = '22023';
  end if;
  update public.bookings set status = 'cancelled'
  where booker_id = me and starts_at > now() and status = 'requested';
  delete from auth.users where id = me;
end;
$$;

revoke all on function public.get_my_settings(), public.delete_my_account(),
  public.friendships_block_guard(), public.blocked_users_unfriend()
  from public, anon, authenticated;
grant execute on function public.get_my_settings(), public.delete_my_account()
  to authenticated, service_role;
