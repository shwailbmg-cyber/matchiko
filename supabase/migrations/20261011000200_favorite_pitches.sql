-- A player's favourite pitches (heart on the pitch list and page).
-- Private: each player reads and changes only their own rows.

create table public.favorite_pitches (
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  pitch_id uuid not null references public.pitches (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, pitch_id)
);

alter table public.favorite_pitches enable row level security;

revoke all on public.favorite_pitches from public, anon, authenticated;
grant select, insert, delete on public.favorite_pitches to authenticated;

create policy favorite_pitches_select on public.favorite_pitches
  for select to authenticated using (user_id = (select auth.uid()));
create policy favorite_pitches_insert on public.favorite_pitches
  for insert to authenticated with check (user_id = (select auth.uid()));
create policy favorite_pitches_delete on public.favorite_pitches
  for delete to authenticated using (user_id = (select auth.uid()));
