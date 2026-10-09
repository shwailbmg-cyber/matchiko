-- Reference data every environment needs (was only in seed.sql).
--
-- XP values come from the Monte Carlo model in docs/economy/simulate_rewards.py
-- (option B, see docs/economy/REWARDS.md): a regular player (6 games/month)
-- reaches Silver in ~6 weeks, Gold in ~3.5 months, Elite in ~7.5 months, and
-- Legend stays rare (~17% of regulars within a year). Coin values are the
-- locked product decisions.

insert into public.cities (id, name_fr, name_ar) values
  ('alger', 'Alger', 'الجزائر'),
  ('oran', 'Oran', 'وهران'),
  ('constantine', 'Constantine', 'قسنطينة'),
  ('blida', 'Blida', 'البليدة'),
  ('annaba', 'Annaba', 'عنابة'),
  ('tizi', 'Tizi Ouzou', 'تيزي وزو')
on conflict (id) do nothing;

insert into public.reward_rules (reason, xp, coins) values
  ('show_up', 30, 20),
  ('first_game', 50, 0),
  ('rate_game', 5, 10),
  ('referee', 40, 50),
  ('win', 15, 30),
  ('goal', 10, 30),
  ('mvp', 25, 30),
  ('pay_online', 0, 15),
  ('invite', 0, 100),
  ('verified', 100, 200),
  ('no_show', -50, -30),
  ('admin', 0, 0)
on conflict (reason) do update set xp = excluded.xp, coins = excluded.coins;

-- Same as before, plus the one-time first_game bonus (ref null → paid once
-- per user thanks to the ledger's unique key).
create or replace function public.complete_booking(p_booking uuid, p_absent uuid[] default '{}')
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  g public.games;
  gp record;
begin
  if not public.manages_booking(p_booking) then
    raise exception 'not your venue' using errcode = '42501';
  end if;
  update public.bookings set status = 'completed'
  where id = p_booking and status = 'guaranteed' and starts_at <= now();
  if not found then
    raise exception 'only started, guaranteed bookings can be completed' using errcode = '22023';
  end if;
  select * into g from public.games where booking_id = p_booking;
  for gp in select user_id from public.game_players where game_id = g.id loop
    if gp.user_id = any (p_absent) then
      update public.game_players set attended = false
      where game_id = g.id and user_id = gp.user_id;
      perform public.apply_no_show(gp.user_id, g.id);
    else
      update public.game_players set attended = true
      where game_id = g.id and user_id = gp.user_id;
      perform public.award(gp.user_id, 'show_up', g.id);
      perform public.award(gp.user_id, 'first_game', null);
    end if;
  end loop;
end;
$$;

revoke all on function public.complete_booking(uuid, uuid[]) from public, anon;
grant execute on function public.complete_booking(uuid, uuid[]) to authenticated, service_role;
