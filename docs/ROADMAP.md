# Matchiko roadmap

Each milestone ships something usable end to end (app + database + tests).
Screen names refer to `SC.<name>` in `design/prototype/*.js`. Placeholder
screens in the app show which one they will become.

| # | Milestone | App screens | Backend | Done when |
|---|---|---|---|---|
| **M0** | **Setup** ✅ | Login (demo + phone OTP), nav shells, settings (language, logout), theme, EN/FR/AR + RTL | Schema, RLS, game-loop RPCs, seed, pgTAP tests | `flutter analyze`, `flutter test`, `supabase/tests/local/run.sh` all green |
| M1 | Real sign-in + profile | `profile`, `settings` (notifications), verification QR sheet | Hosted Supabase project, SMS provider, avatars bucket | A new phone number can sign up, edit their profile, show their verification QR |
| M2 | Pitches + booking | `home` (pitches near you), `detail` (slots), book sheet, `matches` (upcoming + ladder + QR) | Slot availability view, `request_booking` wired, Realtime on bookings | A verified player books a slot and sees it go Requested → Confirmed |
| M3 | Manager app | `mtoday`, `mscan` (camera QR), `mplayers` (verify + referee requests) | `mobile_scanner`; manager RPCs already exist | A manager confirms, scans, verifies and completes games |
| M4 | Matchmaking v1 | `play` (modes, tag friends, positions, city, referee), `searching` (radar), `found` (30 s offer), `confirmed` | `find_matches()` + pg_cron, offers through Realtime, teams balancing | Two test players searching the same slot get matched into one game |
| M5 | After the game + rewards | `rate`, `reflog` (referee report), `wallet` (coins, XP, store teaser) | `rate_game`, `submit_match_report` wired, `reward_rules` tuned | Rewards and penalties show up in the wallet |
| M6 | Online payment + push | `satim` | Edge Functions `satim-create-order` / `satim-callback`, FCM push, reminders | A player pays with CIB/Edahabia and the booking becomes Guaranteed |
| M7 | Suggestions + growth | "Suggested for you", notifications center, teams management, invite friends | Suggestions from history, sponsor/ad slots, store purchases | — |

After each milestone: run the `matchiko-security` skill on the diff.
