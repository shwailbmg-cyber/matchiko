-- A team's usual weekly game (day, hour, pitch), shown on the team page so
-- the captain can book it again in one tap. Booking stays a normal request.

alter table public.teams
  add column usual_weekday smallint check (usual_weekday between 1 and 7), -- ISO, 1 = Monday
  add column usual_hour smallint check (usual_hour between 6 and 23),
  add column usual_pitch_id uuid references public.pitches (id) on delete set null;

grant update (usual_weekday, usual_hour, usual_pitch_id) on public.teams to authenticated;
