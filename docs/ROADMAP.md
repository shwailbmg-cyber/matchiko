# Matchiko roadmap

Each milestone ships something usable end to end (app + database + tests).
Screen names refer to `SC.<name>` in `design/prototype/*.js`. Screens the
prototype doesn't have yet (✗ in `docs/PRODUCT.md` § 4) should be designed in
Claude Design before their milestone starts.

| # | Milestone | App screens | Backend | Done when |
|---|---|---|---|---|
| **M0** | **Setup** ✅ | Login (Google + email code, demo mode), nav shells, settings, theme, EN/FR/AR + RTL | Schema, RLS, game-loop RPCs, tuned rewards, phone privacy, 46 pgTAP tests | analyze, tests and DB tests green |
| M1 | Sign-in + onboarding + profile | splash, onboarding (name, photo, city, positions, level, phone), `profile` + edit, settings (notifications, delete account, legal), verification QR sheet | Hosted Supabase (Paris), Google OAuth client ids, Brevo SMTP, avatars bucket, `delete_my_account()` | A new user signs in with Google or email, completes onboarding and shows their verification QR |
| M2 | Pitches + booking + game page | `home`, pitch list + map + filters, `detail` (slots), book sheet, **game page** (line-up, RSVP, who paid, share to WhatsApp), `matches` | Slot availability view, RSVP + waitlist, reminders T−24 h / T−3 h (pg_cron), Realtime on bookings | A verified player books, opens the game to others, and friends join from a WhatsApp link |
| M3 | Manager app + trust | `mtoday`, **calendar + walk-ins + block slots**, pitches & prices, `mscan` (booking, verification, check-in), `mplayers` (verify, referees, no-show reports), public profile, friends, notifications, report no-show | `mobile_scanner`, reliability %, trust ladder limits, no-show reports + appeals, late-cancel rule | A manager runs a full day from the app; no-shows show on profiles |
| M4 | Matchmaking v1 + teams | `play`, tag friends, `searching`, `found` (30 s), `confirmed`, teams (create, page, recurring game) | `find_matches()` + pg_cron, offers through Realtime, balanced teams, auto-release of unfilled games | Two test players searching the same slot get matched into one game |
| M5 | After the game + rewards + referees | `rate`, `reflog`, `wallet` + history, referee apply / availability / jobs / earnings | `rate_game`, `submit_match_report` wired, referee job board | Rewards and penalties show up in the wallet; a referee picks a job and reports it |
| M6 | Push + venue tools | manager reports (cash, occupancy), staff accounts | FCM push via Edge Function, venue stats | Players get push reminders; a venue sees its weekly numbers |
| M7 | Suggestions + growth | "Suggested for you", invite friends, store (open), sponsor slots | Suggestions from history, store purchases, admin back-office (web) | — |
| Later | Online payment | `satim` | SATIM Edge Functions (needs a bank contract), or BaridiMob receipt pre-payment (see PRODUCT § 2) | A player pays online and the booking becomes Guaranteed |

After each milestone: run the `matchiko-security` skill on the diff. Workflow
and model use: `docs/AI_WORKFLOW.md`.

## Clickable demo (built ahead of M1–M5)

All main screens run in demo mode on sample data (`DemoGameRepository`):
home, pitch + booking sheet, game page (line-up, who's coming, who paid,
cost split, still-coming check, size change, open to others, cancel),
matches + rating, profile, play (search → found → join), notifications,
settings (language, demo "verified" switch), and the manager's today,
scan and players screens. The Supabase `GameRepository` replaces the demo
one milestone by milestone; the database rules already exist.

How to test: CI builds a web demo (GitHub Pages, on `main`) and a demo APK
(workflow artifact on every push, `preview` release on `main`).
