# Matchiko architecture

Matchiko organises small football games (5v5 / 6v6 / 8v8) in Algeria: it gets
enough players together, finds a free pitch, and stops no-shows in a mostly
cash market. This doc is the map: the main loop, how it runs on Flutter +
Supabase, and where each rule is enforced.

Product decisions come from the design hand-off (`design/prototype/BRIEF.md`,
`design/chats/chat1.md`). The prototype `design/prototype/Matchiko.html` is the
visual reference for every screen.

## 1. Stack

| Layer | Choice | Why |
|---|---|---|
| App | **Flutter** (Dart 3, Android first, iOS from the same code) | Draws its own pixels, so the custom design (zellij patterns, diamond nav button, pitch drawings) matches exactly on every phone. Solid RTL for Arabic. Fast on the low-end Android phones common in Algeria. Official Supabase SDK. |
| State | MVVM: `ChangeNotifier` view models + `provider` for injection | The pattern the Flutter team recommends (see the `flutter-apply-architecture-best-practices` skill). Little magic, easy to test. |
| Navigation | `go_router` | Declarative routes, role-based redirects, deep links later. |
| Backend | **Supabase**: Postgres + RLS, Auth (phone OTP), Realtime, Storage, Edge Functions, pg_cron | One managed service. Business rules live in Postgres next to the data, so a modified app can't break them. |
| Payments | Cash at the pitch (QR scan) + **SATIM** (CIB / Edahabia) through an Edge Function | The two ways people actually pay. |
| Push | Firebase Cloud Messaging, sent from an Edge Function | Standard on Android. |

**Why not React Native:** I first suggested it only because the prototype is
HTML/JS. Flutter is the better fit here: the design is fully custom (Flutter
paints it pixel for pixel), the market is mostly low/mid-range Android, and
`supabase_flutter` is official. React Native's only real advantage would be
sharing code with a React website, which isn't planned.

## 2. The big loop

Everything in the app serves one cycle. Each turn of it should make the next
one easier (better matches, more trust, more coins), which is what keeps people
coming back.

```mermaid
flowchart TD
    A[Open app<br/>Home: suggestions,<br/>games missing players] --> B{Want to play}
    B -->|Join an open game| F
    B -->|Play: mode, city, day,<br/>windows, positions, referee| C[Match request]
    B -->|Book a pitch directly<br/>verified only| E
    C --> D[Matchmaking<br/>score games and free slots]
    D -->|Offer, 30 s to accept| F[Game slot reserved<br/>teams balanced by rank,<br/>friends together]
    D -->|Nothing yet| D2[Keep searching or<br/>notify when a game appears]
    D2 --> D
    F --> E[Booking<br/>REQUESTED]
    E -->|Manager takes the call| G[CONFIRMED]
    E -->|Pays online with SATIM| H
    G -->|Cash at the pitch,<br/>manager scans QR| H[GUARANTEED]
    H --> I[Game day: play]
    I --> J[Referee logs goals,<br/>cards, MVP]
    I --> K[Manager marks it completed:<br/>present / absent]
    J --> L[Rewards: XP and coins]
    K --> L
    K -->|Absent| P[No-show penalty<br/>−50 XP −30 coins<br/>2× = 7-day booking ban]
    L --> M[Rate players and pitch<br/>+10 coins]
    M --> N[Rank up, store, badges]
    N --> O[Better suggestions<br/>usual times, city, friends]
    O --> A
```

Three smaller loops feed the main one:

- **Trust loop.** A player shows their verification QR to any stadium
  manager, who checks the ID card in person (name, photo, age 16+) and taps
  Verify (+200 coins). Only verified players can book a pitch; anyone can join
  a game. Verified players can apply to referee, and a manager approves them.
- **Manager loop.** Today's timeline: call the requester → **Confirm**; at the
  pitch, scan the QR after the cash → **Guaranteed**; after the game →
  **Complete** (mark absent players) or **No-show**.
- **Penalty loop.** No-shows cost XP and coins, and 2 no-shows mean a 7-day
  booking ban. Reliability is visible on the profile, so people show up.

## 3. Booking state machine

Enforced in Postgres (`bookings_status_guard` trigger + the RPCs). The app's
`BookingStatus` enum is a copy for display only.

```mermaid
stateDiagram-v2
    [*] --> requested: request_booking()
    requested --> confirmed: confirm_booking() manager
    requested --> guaranteed: SATIM paid (Edge Function)
    confirmed --> guaranteed: scan_booking_qr() manager, cash received
    requested --> cancelled: cancel_booking()
    confirmed --> cancelled: cancel_booking()
    confirmed --> no_show: mark_no_show() manager
    guaranteed --> no_show: mark_no_show() manager
    guaranteed --> completed: complete_booking() manager
    completed --> [*]
```

## 4. System view

```mermaid
flowchart LR
    subgraph Phone[Flutter app]
      V[Views] --> VM[ViewModels] --> R[Repositories] --> S[Services<br/>supabase_flutter]
    end
    S -->|HTTPS + JWT| API[PostgREST + RPC<br/>RLS on every table]
    S -->|WebSocket| RT[Realtime<br/>offers, bookings,<br/>notifications]
    S -->|Phone OTP| AUTH[Supabase Auth]
    API --> DB[(Postgres)]
    RT --> DB
    CRON[pg_cron<br/>matchmaker, expire offers,<br/>reminders] --> DB
    EF[Edge Functions<br/>satim-*, push] --> DB
    EF --> SATIM[SATIM gateway]
    EF --> FCM[Firebase push]
    AUTH --> SMS[SMS provider]
```

Rules of thumb:

- **The app is untrusted.** It reads through RLS and changes important state
  only by calling RPCs (`supabase.rpc('confirm_booking', ...)`). Prices,
  rewards, roles and statuses are computed on the server.
- **Edge Functions only for what Postgres can't do:** talking to SATIM, sending
  push, and later heavier matchmaking. Everything else is SQL.
- **Realtime for the live parts:** the 30-second offer, booking status changes
  for the player, new requests for the manager.

## 5. Data model

Migrations: `supabase/migrations/`. Tests: `supabase/tests/database/`.

| Area | Tables | Notes |
|---|---|---|
| People | `profiles` | Public: handle, name, avatar, city, positions, verified, XP. Private (only through `get_my_profile()`): coins, no-show count, ban. Phone stays in `auth.users`. |
| Places | `cities`, `venues`, `pitches`, `venue_managers` | A venue (complex) has several pitches. Managers are linked to venues, which is what makes someone a manager. |
| Roles | `referees`, `referee_applications`, `verification_requests` | Referee = verified player approved by a manager. |
| Games | `bookings`, `booking_tickets`, `games`, `game_players` | One booking = one 1-hour slot = one game. `booking_tickets` holds the QR secret (booker only). An exclusion constraint prevents double booking. |
| Money | `payments` | SATIM orders. Service role only. |
| Matchmaking | `match_requests`, `match_offers`, `teams`, `team_members`, `friendships` | A request stores mode, friends/team, positions in order, city, day, windows, radius, referee wish. |
| After the game | `match_events`, `player_ratings`, `pitch_ratings` | Written through `submit_match_report()` and `rate_game()`. |
| Rewards | `wallet_ledger`, `reward_rules` | Append-only ledger, each reward paid once per (user, reason, game). Amounts are data (tunable without a release). |
| Inbox | `notifications` | Feeds the in-app inbox and push. |

## 6. Matchmaking (the key feature)

**v1, SQL only (milestone M4):**

1. The player creates a `match_request` (Play screen).
2. A `find_matches()` function runs on insert and every ~15 s via pg_cron. For
   each searching request it scores candidates:
   - **open games** in the same city, day and time window, same format, with a
     free spot for one of the wanted positions (the first choice scores
     higher), and for friends/team mode enough spots on one side;
   - **free slots** at pitches within the radius, when enough compatible
     requests are waiting to fill a game (pooling).

   Suggested score: `position fit (40) + time fit (20) + distance (20) +
   rank closeness (15) + friend/usual-pitch bonus (5)`.
3. The best candidate becomes a `match_offer` (30 s, pushed through Realtime).
   Accept → join the game (team chosen by balance: average XP per side, tagged
   friends kept together). Decline or timeout → next candidate.
4. When a pooled game fills, the system books the slot as `requested` for the
   manager to confirm, like any booking.

**v2 (milestone M7): suggestions.** Use history (usual days, times, pitches,
friends) for a "Suggested for you" feed and pushes like "Yacine is playing
tonight at Kouba, 1 spot left". Same scoring, run ahead of time.

## 7. Security model

Full checklist: `.claude/skills/matchiko-security/SKILL.md`. Summary:

- RLS on every table. Supabase grants everything to `anon`/`authenticated` by
  default, so the migrations **revoke all and re-grant** table by table and
  column by column. A pgTAP test fails if any table lacks RLS or if `anon` has
  any table privilege.
- Every write that matters goes through a `security definer` function with
  `search_path = ''` that checks the caller and their venue.
- Roles come from tables (`venue_managers`, `referees`), never from JWT
  `user_metadata`.
- QR codes are random 128-bit tokens, readable only by the booker, and only
  work for a manager of that venue.
- SATIM: the Edge Function computes the amount from the booking, and the
  callback re-checks the order status with SATIM before marking it paid
  (idempotent).
- No ID photos are stored: verification happens in person. Only avatars go to
  Storage.
- The app ships only the Supabase URL and the publishable key.

## 8. Repo layout

```
app/                  Flutter app
  lib/config/         build-time env (--dart-define-from-file)
  lib/data/           repositories + services (Supabase access)
  lib/domain/models/  pure Dart models (Rank, Position, BookingStatus…)
  lib/routing/        go_router, role-based redirects
  lib/ui/core/        theme tokens, shared widgets (logo, nav, zellij)
  lib/ui/features/    one folder per feature: views/ + view_models/
  lib/l10n/           ARB files en/fr/ar (generated from the prototype)
supabase/
  config.toml         local Supabase (phone OTP, test numbers)
  migrations/         schema, RLS, RPCs
  seed.sql            local dev data (3 Alger venues, test users)
  tests/database/     pgTAP tests
  tests/local/        run tests on plain Postgres when Docker isn't available
design/               Claude Design hand-off (prototype, brief, chat, tools)
docs/                 this file, ROADMAP.md
.claude/skills/       agent skills (Flutter, Dart, Supabase, security)
```

## 9. Open decisions

| Decision | Options | Needed by |
|---|---|---|
| SMS provider for OTP in Algeria | Twilio / Vonage / MessageBird (Supabase built-in) or a local aggregator via the Auth "Send SMS" hook | M1 |
| Supabase region | Frankfurt (eu-central-1) or Paris (eu-west-3): lowest latency from Algeria | M1 |
| SATIM merchant contract | Needs a bank (CIB) agreement and test credentials | M6 |
| XP amounts per action | First guess in `seed.sql` (`reward_rules`), coins are locked | M5 |
| Android package id | Currently `dz.matchiko.matchiko` | Before the first store upload |
| Maps / distance | Plain lat/lng + Haversine first; PostGIS when needed | M4 |
