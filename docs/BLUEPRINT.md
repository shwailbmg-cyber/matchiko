# Matchiko blueprint: from demo to a real working app

One document that says what is built, what is missing, and how each missing
part should work: features, screens, the matching algorithm, the reward
system and the security system. It builds on `PRODUCT.md`, `FEATURES.md`
(feature IDs like C6, F2 come from there), `ARCHITECTURE.md` and
`economy/REWARDS.md`. Items marked **❓** need your decision (list in § 8).

Releases used below:

- **R1 = launch blockers.** Without them real users hit a wall or can cheat.
- **R2 = first months.** Makes people stay and venues depend on the app.
- **R3 = later.** Growth and money.

---

## 1. Supabase or Firebase?

**Keep Supabase as the backend. Use Firebase for push delivery only.**

| Need | Supabase (now) | Firebase alternative | Verdict |
|---|---|---|---|
| Data shape | Postgres: bookings, games, players, teams, ledger are linked tables with joins | Firestore: documents, no joins, data copied in many places | Supabase |
| "No double booking" | One exclusion constraint, impossible to break | Needs transactions in Cloud Functions, easy to get wrong | Supabase |
| Anti-cheat rules | RLS + SQL functions next to the data; 28 migrations and ~190 database tests already prove them | Security Rules language + Cloud Functions; all rules and tests rewritten | Supabase |
| Matching and scoring | One SQL query over games, players, friends, blocks | Many reads per search, billed per read | Supabase |
| Money ledger (XP, coins) | Append-only table, unique keys, sums always exact | Possible, but counters drift without care | Supabase |
| Cost | Free now; Pro $25/month fixed before launch | Pay per read/write/function call, grows with every feed refresh | Supabase |
| Region | Paris, closest to Algeria | Europe too | Equal |
| Offline use | Weak (we cache the last screens ourselves) | Firestore offline is very good | Firebase, but not needed: bookings must be online anyway |
| Push to phones | None of its own | **FCM**, free, required on Android | **Firebase (already set up)** |
| Phone-number login | Via hook + WhatsApp/SMS provider | Built in, but SMS to Algeria is paid either way | Equal |

Supabase's weak points and what to do about them:

- Free projects **pause after 7 idle days** and allow 500 MB → move to
  **Pro ($25/month) before real users** (also gives daily backups).
- Built-in email sends only a few emails per hour → add **Brevo SMTP**
  (free 300/day) before launch.
- Lock-in is low: it is plain Postgres; the schema and functions move to
  any Postgres host.

Switching to Firebase would mean rewriting the whole backend and its tests
for no gain. **Decision proposed: closed.**

---

## 2. Where we are

**Live on the real backend** (Supabase project `matchiko`, Paris):
sign-in by email code, onboarding, profile + photo, 69 wilayas, pitch list
with filters and favourites, booking with status ladder
(Requested → Confirmed → Guaranteed → Completed), opening hours rule, game
page (line-up, who paid, cost split in 50 DA steps, still coming, size
change, open to others), real QR codes + camera scan (booking,
verification, check-in), manager today / week calendar / walk-ins / blocked
slots / venue settings / reports / staff, friends, blocks, teams with a
usual game, referee apply / jobs / match report, wallet with ledger, ratings
(pitch + players), notifications inbox + push pipeline, matchmaking v1
(`find_match`), reliability %, no-show reports, privacy setting, delete
account, EN/FR/AR with RTL. Security review done and fixed.

**Not yet proven on a real phone:** the full loop with two accounts
(`docs/TESTING.md`), push delivery, email code template.

**Missing (this document):**

| Area | Missing | Release |
|---|---|---|
| Identity | One ID card = one account (A4), age 15+ check (A5), phone login by WhatsApp code (A1), change email/phone (A9) | R1 / R2 |
| Games | Waitlist (C6), guests on the server (C5), WhatsApp invite link (C3), game level tag (C16), T−10 h check with flag to manager (C7), score + MVP vote without referee (H1, H2), WhatsApp group link (C13) | R1 |
| Trust | Trust ladder limits (F2), appeals (F5), rating weights (F8), fraud checks (F9), venue blacklist (E12) | R1 / R2 |
| Matching | Distance, 30 s server hold, reliable-with-reliable (D6), pooling into new games (D4), team vs team (D7), "ping me" (D8), find a replacement (C8), suggestions (B2) | R1 / R2 |
| Rewards | Daily caps, invite reward (I7), streaks (I4), badges (I3), leaderboards (I5), store (I6) | R1 / R2 / R3 |
| Manager | Prices by time (E7), special days (E8), weekly subscription slot (E6), cash day close (E11), staff rights (E13), last-minute deals (E18), equipment loan (E16) | R2 |
| Money | Venue plan: commission statement or subscription (M2, M3) | R2 |
| Admin | Back-office: venues, managers, reports, appeals, suspensions, reward rules (N1–N6) | R1 (small) |
| Algeria | Communes (B8), weekend Fri–Sat (O1), Ramadan mode (O2), map (B4) | R1 / R2 |
| Operations | Crash reports (P1), analytics (P2), force update (P3), terms + privacy (P4), SMTP, Supabase Pro, Play listing | R1 |

---

## 3. Features to build

Each feature: the rule, then what the server and the app need.

### 3.1 Identity and trust (R1)

**One ID card = one verified account (A4).** At verification the manager
types the ID card number. The server stores only
`HMAC-SHA256(number, server secret)` in `profiles.id_hash` (unique). A second
account with the same card is refused, and a banned person cannot start
again with a new email. No ID photo, no readable number is kept.

**Age 15+ (A5).** The manager also types the year of birth from the card.
Under 15 → verification refused. (`ARCHITECTURE.md` still says 16+;
`FEATURES.md` decided 15+. This document uses **15+**.)

**Trust ladder (F2), enforced in SQL:**

| Level | Condition | Limits |
|---|---|---|
| New | Signed up | Join games only; at most **2 upcoming** games |
| Verified | ID checked | Book pitches; **1** pending request; 4 upcoming games |
| Reliable | Verified + ≥ 5 completed games + reliability ≥ 90 % | **3** pending requests; first in the manager's queue; first in matching |
| Restricted | Reliability < 70 % after ≥ 5 games | Join only; matched last; cannot open games to strangers |
| Banned | 2 no-shows in 60 days → 7 days; 3rd → 30 days ✅ | Nothing new; existing games stay |

**Reliability %** = shows ÷ (shows + no-shows + cancellations), last 20
games. New players show "New" instead of 100 %.

**Appeals (F5).** A player can contest a no-show or a report within 48 h
(one tap + a short message). An admin decides; if accepted the penalty is
reversed by a ledger entry (never by editing history).

**Venue blacklist (E12, R2).** A manager can refuse one player at his venue
only. That player no longer sees this venue's slots.

### 3.2 Games (R1)

- **Waitlist (C6).** Full open game → "Join waitlist". When a spot frees,
  the first in line gets a 10-minute offer (push), then the next.
- **Guests (C5).** The booker adds "Karim (guest)". Guests fill a spot and
  count in the cost split; they earn nothing and cannot be rated.
- **Invite link (C3).** `https://matchiko.app/g/<short code>` opens the
  game in the app (Android App Links) or the store page. The code is
  random and can be reset by the booker. ✅ A domain will be bought
  (name to choose, e.g. `matchiko.app`).
- **Level tag (C16).** Casual / Competitive, chosen by the booker.
  Beginners are never matched into Competitive games.
- **Still coming? (C7).** Decided rule: T−24 h reminder; **T−10 h** "Still
  coming?"; at **T−8 h** players who did not answer are flagged to the
  booker and the manager, who can mark them "not confirmed" (frees the
  spot for the waitlist). Today the server asks at T−2–3 h only: change.
- **Result without a referee (H1, H2).** The booker enters the score; each
  player confirms or disputes with one tap; with ≥ 50 % confirmations it
  counts. Players vote for the MVP (one vote, not for yourself); MVP needs
  ≥ 3 votes.
- **WhatsApp group link (C13).** The booker pastes a group link on the
  game page; only players of the game see it.
- **Recurring game (C10, R2).** A team's usual game creates next week's
  booking request automatically each week until stopped.

### 3.3 Manager and venue (R2)

- **Prices by time (E7).** A price table per pitch: default, evening,
  weekend (Fri–Sat), Ramadan nights, student. The server picks the price
  at booking time; the app never sends a price.
- **Special days (E8).** Closed days and special hours (Eid, Ramadan).
- **Subscription slot (E6).** "Team X, every Tuesday 21:00 until June":
  one entry blocks the slot every week.
- **Staff rights (E13).** Owner (everything) / Staff (today, scan,
  walk-ins; no prices, no staff, no reports).
- **Cash day close (E11).** End of day: expected vs. received per staff
  member; the owner sees differences.
- **Last-minute deal (E18).** A slot still empty 3 h before can get a
  discount; pushed to nearby players with "ping me" on.
- **Equipment loan (E16).** Bibs/ball lent against a deposit; the app
  records who has what.

### 3.4 Business (R2)

- **Plan A, 10 % commission (M2).** Only on games booked by players in
  the app and completed. Walk-ins are free. On the 1st of each month the
  server writes a **statement** per venue (list of games, total, 10 %);
  the owner sees it in the app and pays BMG by transfer/cash; an admin
  marks it paid. Two unpaid statements → the venue is hidden from players.
- **Plan B, fixed monthly fee (M3).** Same statement screen, fixed amount.
- Cash never passes through the app.

### 3.5 Admin back-office (R1, small)

A web page (Flutter web, same codebase, role `admin`) with: add venue +
first manager; search a user; suspend / unsuspend user or venue; queue of
reports and appeals; edit reward rules and caps; broadcast a notification;
city numbers (users, games, no-show rate). Every admin action is written to
an audit log.

### 3.6 Algeria-specific

- **Communes (B8, R1).** 1,541 communes under the 69 wilayas, so small
  towns are covered. Needs the official list after decree 26-206.
- **Weekend Fri–Sat (O1, R1).** Calendars, weekend prices, suggestions.
- **Ramadan mode (O2, R2).** One server switch per year: evening windows
  move to 22:00–02:00, Ramadan prices apply, quiet hours move.
- **Map (B4, R2).** OpenStreetMap tiles with `flutter_map` (free, no key).

### 3.7 Operations (R1)

Supabase Pro + Brevo SMTP; email template with the 6-digit code; Sentry
(crashes); a minimum-version check at start (force update); terms and
privacy policy in 3 languages (legal review); Play Console internal test
→ closed test → production.

---

## 4. Screens to design and build

All existing screens stay. These are new or changed. "From" = how the user
gets there.

### Player

| # | Screen | What is on it | From | Rel. |
|---|---|---|---|---|
| P1 | **Join by link** | Game card (pitch, time, players, price per player), "Join" or "Sign in to join" | WhatsApp link | R1 |
| P2 | **Waitlist state** on the game page | Position in line, "Leave waitlist"; 10-minute offer banner with countdown | Game page | R1 |
| P3 | **Add guest** sheet | Name, position, team | Game page (booker) | R1 |
| P4 | **Result** sheet | Score entry (booker), "Confirm / Not correct" (players), MVP vote list | Game page after the game | R1 |
| P5 | **Appeal** sheet | The penalty, reason, text field, status (sent / accepted / refused) | Notification, wallet history | R1 |
| P6 | **Trust level** card | Current level, limits, what is needed for the next level | Profile | R1 |
| P7 | **Commune picker** | Wilaya → commune search | Onboarding, edit profile, Play | R1 |
| P8 | **Play v2** | Adds: distance slider (needs location or commune), level (casual/competitive), game size, "ping me any time" switch | Play tab | R1 |
| P9 | **Offer** (found) v2 | Real 30 s server countdown, why this game (position, distance, friends), "Pass" | Push / searching | R1 |
| P10 | **New game proposal** (pooling) | "8 players ready · Kouba Five · Tue 21:00", list of players, "I'm in"; for the host: "I book this game" | Push / searching | R2 |
| P11 | **Team challenge** | My team, opponent team (record, level), slot, "Accept / Refuse" (captain) | Team page, push | R2 |
| P12 | **Suggested for you** row | 3–5 cards with the reason ("Your usual Tuesday 21:00") | Home | R2 |
| P13 | **Map** | Pitches as pins, filter chips, card on tap | Pitches | R2 |
| P14 | **Badges** | Grid: earned and locked, with the rule | Profile | R2 |
| P15 | **Leaderboard** | Tabs wilaya / pitch / friends; month; my place | Wallet or profile | R2 |
| P16 | **Streak** chip | Flame + weeks, on Home and profile | Home | R2 |
| P17 | **Invite friends** | My link/code, list of invited friends and their state (signed up / verified / played) | Friends, wallet | R1 |
| P18 | **Store** + item + my vouchers | Items with coin price, "Get", voucher QR with expiry | Wallet | R3 |
| P19 | **Change email / phone** | New value → code → done | Settings | R2 |
| P20 | **Force update** | "Update Matchiko" + store button | App start | R1 |

### Stadium manager

| # | Screen | What is on it | Rel. |
|---|---|---|---|
| M1 | **Verify v2** | Checklist (name, photo) + ID number field + year of birth; errors "card already used", "under 15" | R1 |
| M2 | **Not confirmed list** | Players who did not answer at T−8 h, call button, "Mark not confirmed" | R1 |
| M3 | **Price table** | Rows per pitch: default / evening / weekend / Ramadan / student | R2 |
| M4 | **Special days** | Calendar of closed days and special hours | R2 |
| M5 | **Subscription slot** | Team/customer, weekday, hour, end date | R2 |
| M6 | **Staff rights** | Owner / Staff switch per person | R2 |
| M7 | **Day close** | Expected, received, difference, per staff; "Close the day" | R2 |
| M8 | **Statement** | Month, plan, list of app games, amount due, paid / unpaid | R2 |
| M9 | **Blacklist** | Players refused at this venue, add/remove with reason | R2 |
| M10 | **Deals** | Empty slots in the next 3 h, discount picker, "Send" | R2 |
| M11 | **Scan voucher** | Fourth scan mode: store voucher → valid / used | R3 |

### Referee

| # | Screen | What is on it | Rel. |
|---|---|---|---|
| F1 | **Referee rating** (player side) | Stars + tags (fair, on time, strict) in the rate screen | R2 |
| F2 | **Referee profile** | Games refereed, rating, availability | R2 |

### Admin (web)

| # | Screen | What is on it | Rel. |
|---|---|---|---|
| A1 | Sign-in + dashboard | Numbers per wilaya, queues | R1 |
| A2 | Venues | Add venue, pitches, first manager; hide/show; plan | R1 |
| A3 | Users | Search, profile, history, suspend, reverse a penalty | R1 |
| A4 | Reports and appeals | Queue, both sides, decide | R1 |
| A5 | Reward rules | Amounts, caps, store items | R2 |
| A6 | Fraud flags | Flagged users/venues with the reason | R2 |
| A7 | Broadcast | Message to a wilaya or everyone | R2 |
| A8 | Statements | Venue statements, mark paid | R2 |

**Design order suggested for Claude Design:** P8, P9, P1, P4, M1, M2, P6,
P17, then P10–P12, M3, M8, then the rest.

---

## 5. Matching algorithm (v2)

Goal, in order: **(1) games that really happen** (full, people show up),
**(2) fair and fun** (similar level, friends together), **(3) fast**
(an answer in seconds).

Today (`find_match`): one SQL score over open games in my wilaya
(position 40, time 20, level 15, friend 5), skips blocked players. v2 keeps
the same idea and adds what is missing.

### 5.1 The request

`match_requests`: mode (solo / friends / team), party (me + tagged
friends, or my team), positions in order, wilaya + commune or GPS point,
radius (km), days, time windows, game size wanted (any or a list), level
(casual / competitive / any), referee wish, "ping me any time".

Party size **P** = number of people who must land in the same team.

### 5.2 Hard filters (a game is not even considered if…)

1. Not open, already started, or starts in less than 45 minutes.
2. Outside the wilaya/radius, day or time windows (± 1 h tolerance).
3. Fewer than P free spots **on one side** (spots held by other pending
   offers count as taken).
4. Any player in the game blocked me or is blocked by me; or the venue
   blacklisted me.
5. I am banned, already in a game that overlaps (± 1 h), or over my
   trust-level limit.
6. Level: a "beginner" is never offered a Competitive game; a Competitive
   game is offered only within ± 1 level of its average.

### 5.3 Score (0–100)

| Part | Max | How |
|---|---|---|
| **Position** | 30 | The game *needs* my 1st choice: 30 · 2nd: 22 · 3rd: 15 · only a spot nobody needs: 8. "Needs" = the side has fewer of that position than the line-up for its size (always 1 keeper per side). |
| **Time** | 15 | Inside my window: 15 · within 1 h: 8 |
| **Fill** | 10 | 10 × (players ÷ capacity): nearly full games first, so games complete |
| **Distance** | 15 | 15 × (1 − distance ÷ radius). Without GPS: same commune 15, same wilaya 8 |
| **Level** | 15 | 15 × (1 − \|my level − game average\| ÷ 3) |
| **Reliability** | 5 | Close to the game's average reliability |
| **Social** | 7 | A friend is in the game +4 · played together and rated ≥ 4★ +2 · favourite pitch +1 |
| **Habit** | 3 | My usual weekday/hour or usual pitch |

A game is offered only if its score is **≥ 40**.

**Level of a player** (1–4): the self-rated level at first. After 5 rated
games it moves toward the skill stars given by others (weighted, § 6.5),
at most one step per 10 games. Rank XP is **not** skill (it rewards
playing a lot), so it is no longer used for balance.

### 5.4 Offers (30 seconds, held on the server)

1. The best game becomes a row in `match_offers` and **holds P spots for
   30 s**. Sent by Realtime (app open) and push.
2. **Accept** → the server joins the party in one transaction (locks the
   game row, re-checks every filter). **Pass or timeout** → the hold is
   released, that game is not offered again to this request, the next
   best is offered.
3. One pending offer per request. Three passes in a row → the app asks
   to widen the search. Three timeouts → the request is paused.
4. **Queue fairness:** when two requests want the same last spot, the
   higher trust level wins, then the older request. Players under 80 %
   reliability get offers 60 s later (D6).

### 5.5 Nothing fits: make a new game (pooling, R2)

Every minute the server groups waiting requests by wilaya, day,
overlapping window and level band. A new game is proposed when:

- the group has **≥ 80 % of a game** (8 of 10 for 5v5), and
- a pitch is free in that window (open hours, not busy, not blacklisted),
  chosen to minimise the total distance, and
- one member is **Verified or Reliable**: he becomes the **host**.

Everyone gets "New game · Kouba Five · Tue 21:00 · 8 players ready"
(2 minutes to answer). The host must tap **"I book this game"** (he is the
one the manager calls and who owes the pitch). If ≥ 80 % say yes, the
server creates a normal booking request in the host's name, open to
others, and the usual loop starts. No verified member → nothing is
created; the app tells them to get verified.

### 5.6 Team vs team (D7, R2)

A captain asks for an opponent (size, days, windows, wilaya). Two team
requests match when the size is the same, windows overlap and **team
rating** is close (Elo: starts at 1000, K = 24, updated after each
confirmed result; gap ≤ 150). Teams that met in the last 14 days come
last. Both captains get the proposal with a free pitch (as in pooling);
both accept → booking in the first captain's name, sides fixed.

### 5.7 Balancing the two sides (inside one game)

Used for every non-team game, run at each roster change until kick-off;
the booker can still swap players.

1. Friend groups (tagged friends) are treated as one block.
2. One keeper per side first.
3. Blocks sorted by total level, strongest first; each goes to the side
   with the lower total (if it has room).
4. One pass of swaps between sides to reduce the level difference and to
   spread positions (not all defenders on one side).

### 5.8 A spot frees up late (C8)

Order: (1) the waitlist; (2) if empty and the game is in less than 24 h:
push to the 20 best candidates by the same score among players with
"ping me" on, right position, ≤ 5 km, reliability ≥ 85 %. First to accept
gets it.

### 5.9 Suggestions (B2, R2)

Each night the server builds a small habit profile per player: usual
weekdays and hours, top 3 pitches, closest friends, usual size. Home shows
open games scored with the same formula (Habit weight ×3) with the reason.
At most **one** suggestion push per day, never in quiet hours
(22:00–08:00; shifted in Ramadan mode).

### 5.10 How it runs

- Triggered by events (new request, game opened, spot freed, offer
  answered) plus a `pg_cron` sweep every minute (expire offers, pooling).
- All in SQL functions; the app only creates the request and answers
  offers. No client can choose its own game outside the filters.
- Numbers to watch: fill rate, time to first offer, accept rate, share of
  matched games that are completed, no-show rate of matched players.

---

## 6. Reward system (v2)

### 6.1 What stays (decided)

Two numbers: **XP** (rank, never spent) and **coins** (wallet, spent in
the store). Ranks: Bronze 0 · Silver 500 · Gold 1000 · Elite 2000 ·
Legend 3500.

| Action | XP | Coins |
|---|---|---|
| Show up to a game | 30 | 20 |
| First game ever | 50 | 0 |
| Get verified | 100 | 200 |
| Win | 15 | 30 |
| Score (once per game) | 10 | 30 |
| MVP | 25 | 30 |
| Rate the game | 5 | 10 |
| Referee a game | 40 | 50 |
| Invite a friend who plays | 0 | 100 |
| Cancel | −20 | −10 |
| No-show | −50 | −30 |

### 6.2 When a game pays (anti-farming, R1)

A game gives rewards only if **all** are true:

1. The booking was **Guaranteed** (cash scanned at the venue) and then
   **completed by the manager**.
2. At least **6 real players** (not guests) were marked present.
3. The player was **checked in by QR** or marked present by the manager.
4. Win / goal / MVP need a **referee report** or a **confirmed result**
   (§ 3.2).

Caps per player: **2 rewarded games per day, 8 per week**; ratings
rewarded twice a day; refereeing 3 a day; invites 10 a month. Above the
cap the game still counts for stats and reliability, not for XP/coins.

**Invite reward (I7):** paid once, when the invited friend is **verified**
and has **completed a first game** in which the inviter did not play
(stops two-account farming). Each side gets it: inviter +100 coins,
friend +50 coins ✅.

### 6.3 Penalties

| Event | Effect |
|---|---|
| Cancel (booker) or leave (player), any time (same cost inside 24 h ✅) | −20 XP, −10 coins, lowers reliability |
| No-show | −50 XP, −30 coins, lowers reliability |
| 2 no-shows in 60 days | 7-day ban on booking and joining |
| 3rd no-show in 60 days ✅ | 30-day ban |
| Confirmed bad-behaviour report | Admin decides: warning, 7/30-day suspension, permanent |
| Manager cancels | No cost to players |

Penalties are ledger entries; an accepted appeal adds a reversing entry.

### 6.4 Keeping people playing (R2)

- **Weekly streak (I4).** A week runs Sunday–Saturday. Playing at least
  one rewarded game keeps the streak. Bonus at the end of each week:
  +10 XP × streak length (max +50). A missed week resets it.
- **Badges (I3)**, shown on the profile, no coins:
  First game · 10 / 50 / 100 games · Hat-trick (3 goals in one game) ·
  Wall (keeper, clean sheet) · Iron man (4-week streak) · Always there
  (20 games at 100 % reliability) · Fair play (≥ 4.5★ over 10 games) ·
  MVP ×5 · Referee ×10 · Captain (team with 10 games) · Explorer
  (5 different pitches) · Host (opened 10 games that were completed).
- **Leaderboards (I5).** Monthly, by wilaya, by pitch and among friends.
  Score = XP earned in the month. Only players with reliability ≥ 85 %.
  Top 3 per wilaya: a profile frame for the next month + 100 / 60 / 30
  coins. Ranks never reset; boards reset monthly.

### 6.5 Ratings (F8)

- Two separate things: **skill stars** (feeds the level used in
  matching) and **fair-play tags** (shown on the profile).
- A rating counts more when the rater is verified and reliable
  (weight 1.0; unverified 0.5; under 80 % reliability 0.3).
- The same person counts once per 7 days for the same teammate.
- Ratings are shown only as averages after 5 raters; nobody sees who
  gave what.

### 6.6 Store (R3)

Rate: **1 coin ≈ 0.2 DA** (about 5 % back on what a player spends).

| Item | Coins | Who pays for it |
|---|---|---|
| Profile frame | 150 | free |
| Community access | 300 | free |
| Free referee (200 DA) | 1,000 | BMG / referee pool |
| Pitch discount 10 % | 1,250 | partner venue |
| Tournament ticket | 2,500 | organiser |
| Sponsor jersey | 4,000 | sponsor |

Buying an item moves coins in the ledger and creates a **voucher** (random
code + QR, valid 30 days, single use). The manager scans it (new scan
mode); the server marks it used. Coins never expire ✅.
Watch each month: coins created vs. spent; adjust store prices, never the
earn amounts already promised.

---

## 7. Security system

Rule number one stays: **the app is untrusted.** Every rule lives in the
database or in Edge Functions.

### 7.1 What people will try, and the defence

| They want | Attack | Defence | Status |
|---|---|---|---|
| Free XP/coins | Write to the ledger, fake games | No client writes; rewards only inside server functions; § 6.2 conditions and caps | Done; conditions + caps **R1** |
| Dodge a ban | New account | One ID card = one account (HMAC) | **R1** |
| Fake "Guaranteed" | Change status | Status changes only through manager functions for *their* venue; state machine trigger | Done |
| Fake QR | Guess a code | 128-bit random token, booker-only, venue-checked | Done |
| Become manager/referee/admin | Edit own role | Roles are rows in tables written by admins/managers only | Done; `admins` **R1** |
| Dodge a no-show | Leave after kick-off | Blocked after start | Done |
| Stalk a player | Read phone, games, location | Phone only for the venue manager of a booking; "who sees my games"; no exact location stored (commune or rounded point) | Done; location **R1** |
| Spam | Friend requests, open/close games, reports | One notification per pair/day, once per game; rate limits (§ 7.3) | Partly; limits **R1** |
| Manager + friends farm coins | Fake completed games | Caps, 6-player rule, per-venue fraud signals, admin freeze | **R1/R2** |
| Steal an account | Guess the email code | 6-digit code, 10-minute life, attempt limits, CAPTCHA on "send code" | Settings **R1** |
| Read the database from a stolen APK | Use the app key | Only the public key ships; RLS on every table; tests fail if a table has no RLS | Done |

### 7.2 Layers

1. **Identity.** Email code or Google; later WhatsApp code. Session in the
   phone's secure storage. Verified = ID seen in person + ID hash + age.
2. **Authorisation.** RLS on every table; default grants revoked; writes
   that matter only through `security definer` functions with
   `search_path = ''` that check the caller and the venue.
3. **Integrity.** Booking state machine; no double booking (exclusion
   constraint); append-only ledger with one reward per (user, reason,
   game); idempotent functions; opening-hours and price computed on the
   server.
4. **Abuse limits.** § 7.3.
5. **Detection.** § 7.4.
6. **Privacy.** § 7.5.
7. **App hardening.** Obfuscated release builds, no backups of app data,
   HTTPS only, camera only on scan screens, no secrets in the app.
8. **Operations.** § 7.6.

### 7.3 Rate limits (R1)

One small table `rate_limits(user, action, window)` checked inside the
functions:

| Action | Limit |
|---|---|
| Booking requests | by trust level (1 / 3 pending), 6 per day |
| Join / leave games | 10 per day |
| Match searches | 30 per hour |
| Friend requests | 20 per day |
| Reports | 5 per day |
| Support messages | 5 per day |
| Verify attempts (per manager) | 60 per day |
| Sign-in codes | Supabase Auth limits + CAPTCHA (Cloudflare Turnstile) |

### 7.4 Fraud signals (R2)

A nightly job writes rows in `fraud_flags` for an admin to review; nothing
is punished automatically.

- Venue: completed games with no QR check-ins; far more completed games
  than its opening hours allow; the same small group in most games.
- Players: the same two accounts always in the same games and always
  rating each other 5★; several accounts on one device (a hashed device
  id is stored with the push token); invite chains where invited
  accounts play once and stop.
- Manager: many verifications in a few minutes; verifications of accounts
  that never play at his venue.

An admin can freeze rewards for a user or a venue, and reverse entries.

### 7.5 Privacy and law

- **Law 18-07** (Algerian personal data law, authority ANPDP): declare the
  processing before launch; consent screen for location and
  notifications; servers are in the EU (say so in the policy). ❓ legal
  review.
- Data kept as small as possible: no ID photos, ID number only as a hash,
  location as commune or a point rounded to ~500 m.
- **Retention:** notifications 90 days; support messages 1 year;
  match requests 30 days; reports 1 year after closing. Deleting an
  account removes personal data and keeps anonymous game history.
- Minimum age 15; no public search by phone number.

### 7.6 Operations

- **Backups:** Supabase Pro daily backups; a monthly restore test.
- **Admin audit log:** every admin and manager action that changes
  someone else's data (verify, complete, no-show, suspend, reverse) is
  written to an append-only table.
- **Admins:** separate `admins` table (owner / support); admin sign-in
  with a second factor (TOTP).
- **Secrets:** only in Supabase secrets, Vault and GitHub secrets; rotate
  the database password and tokens every 6 months or when someone leaves.
- **Monitoring:** Sentry for app crashes; Supabase security advisor run
  in CI; alerts on Edge Function errors.
- **Each release:** database tests, `matchiko-security` and
  `owasp-mobile-flutter` reviews (already in the build loop).

---

## 8. Decisions

Answered (November 2026):

| # | Question | Answer |
|---|---|---|
| 1 | 3rd no-show in 60 days = 30-day ban | ✅ Yes |
| 2 | Invited friend also gets +50 coins | ✅ Yes |
| 3 | Coins expire after 12 months | ✅ No, coins never expire |
| 4 | Leaving inside 24 h costs more | ✅ No, same cost as any cancellation |
| 6 | Open games show player names to everyone by default | ✅ Yes (default of "who sees my games" becomes *everyone*; each player can still switch to friends / nobody) |
| 7 | A domain for invite links | ✅ Yes (name to choose and buy) |
| 8 | Terms, privacy policy, 18-07 declaration | ✅ Claude drafts the texts in 3 languages; the declaration to the ANPDP is filed by BMG as the company. A lawyer's check is still advised before production |

Still open:

- **5. Venue managers: one owner?** Today every manager of a venue has the
  same rights, so a staff member added last week can remove the person who
  added him and change prices. Proposal: the first manager of a venue is
  its **owner**. Only the owner adds/removes people, changes prices and
  sees money reports; **staff** can confirm, scan, add walk-ins and mark
  no-shows. Ownership can be handed to someone else by the owner or by a
  BMG admin.
- **9. Venue plans:** commission % and monthly fee (not decided yet).

---

## 9. Build order

Each step = database + app + tests, pushed with CI green (the build loop
in `LOOP.md`). Screens marked "design first" should go through Claude
Design before the step starts.

**R1, launch blockers**

- S23 Real-phone test of the loop (`TESTING.md`), fixes, email template,
  SMTP, Supabase Pro.
- S24 Verification v2: ID hash, age, trust ladder limits, trust card (M1, P6).
- S25 Reward conditions and caps (§ 6.2), rate limits (§ 7.3).
- S26 Game: waitlist, guests, level tag, T−10 h / T−8 h flow, "not
  confirmed" list (P2, P3, M2).
- S27 Result + MVP vote without referee (P4); appeals (P5).
- S28 Matching v2 part 1: distance + communes, server-held 30 s offers,
  queue fairness, "ping me", replacement push (P7, P8, P9).
- S29 Invite link + invite reward (P1, P17) (needs the domain).
- S30 Admin back-office v1 (A1–A4) + audit log.
- S31 Operations: Sentry, force update (P20), weekend Fri–Sat, terms and
  privacy texts, Play internal test.

**R2, first months**

- S32 Prices by time, special days, subscription slots, staff rights
  (M3–M6).
- S33 Matching v2 part 2: pooling, team vs team with Elo (P10, P11).
- S34 Suggestions + habit profile (P12); map (P13).
- S35 Streaks, badges, leaderboards (P14–P16); rating weights; referee
  rating (F1, F2).
- S36 Venue statements (plan A/B), day close, blacklist, deals (M7–M10).
- S37 Fraud signals + admin tools (A5–A8); Ramadan mode; change
  email/phone (P19).

**R3, later**

- S38 Store + vouchers (P18, M11), sponsors, premium.
- S39 Online payment (SATIM or BaridiMob receipt).
- S40 Tournaments, leagues, communities, in-app chat.
