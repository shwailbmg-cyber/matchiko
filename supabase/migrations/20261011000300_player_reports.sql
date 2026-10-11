-- Players report a no-show or bad behaviour. A no-show report needs a game
-- both players were in; managers review them later (LOOP.md S14). Reports
-- never change XP or bans by themselves: a manager or BMG confirms first.

create type public.report_reason as enum ('no_show', 'late', 'rude', 'unsafe', 'other');

create table public.player_reports (
  id bigint generated always as identity primary key,
  reporter_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  reported_id uuid not null references auth.users (id) on delete cascade,
  game_id uuid references public.games (id) on delete set null,
  reason public.report_reason not null,
  note text not null default '' check (char_length(note) <= 500),
  created_at timestamptz not null default now(),
  check (reporter_id <> reported_id),
  check (reason <> 'no_show' or game_id is not null),
  unique nulls not distinct (reporter_id, reported_id, game_id)
);
create index player_reports_reported_idx on public.player_reports (reported_id);

alter table public.player_reports enable row level security;

revoke all on public.player_reports from public, anon, authenticated;
grant select on public.player_reports to authenticated;
grant insert (reported_id, game_id, reason, note) on public.player_reports to authenticated;

-- Reporters see their own reports only.
create policy player_reports_select on public.player_reports
  for select to authenticated using (reporter_id = (select auth.uid()));

-- About a game: both players must have been in it.
create policy player_reports_insert on public.player_reports
  for insert to authenticated
  with check (
    reporter_id = (select auth.uid())
    and (
      game_id is null
      or (
        exists (select 1 from public.game_players gp
                where gp.game_id = player_reports.game_id and gp.user_id = (select auth.uid()))
        and exists (select 1 from public.game_players gp
                    where gp.game_id = player_reports.game_id and gp.user_id = player_reports.reported_id)
      )
    )
  );
