# Matchiko product spec (draft for discussion)

What the full app should do, and why. It builds on the locked decisions in
`design/prototype/BRIEF.md`. Items marked **❓** need your decision.

## 1. What similar apps teach us

| App (market) | What they do | What we take |
|---|---|---|
| **Playtomic** (padel/tennis, EU) | Open matches anyone can join; a private booking can be turned into an open match. Unfilled open matches auto-cancel a few hours before. Full matches can't be cancelled in the last 24 h. No-shows are reported by the players who came; the absent player owes the court fee as a debt before they can use the app again, and the match no longer counts for levels. ([1](https://playerhelp.playtomic.com/hc/en-gb/articles/43240624037393), [2](https://playerhelp.playtomic.com/hc/en-gb/articles/19831672824465), [3](https://helpmanager.playtomic.com/hc/en-gb/articles/46236279793425-Convert-a-private-booking-into-an-open-match)) | "Open my game" button. Auto-release of unfilled games. 24 h cancellation rule. Players can report no-shows. No-show = debt/ban before booking again. |
| **Footy Addicts** (football, UK) | Organisers host recurring games. Attendance list; no-show or late lowers a visible reliability score. Pay to secure a spot, refunds as app credit. 16+. ([1](https://www.footyaddicts.com/), [2](https://blog.footyaddicts.com/what-is-footy-addicts/)) | Reliability % on every profile. Late = no-show. **Hosts** for recurring weekly games. Age 16+ check at verification. |
| **Fubles** (football, Italy) | Find a game, one-click join, rate teammates and opponents after every game, stats profile. Free for players; money from sports centres. ([1](https://apps.apple.com/app/id439712991), [2](https://app.dealroom.co/companies/fubles)) | Post-game ratings and stats. Free for players, revenue from venues/sponsors. Watch out: in pickup apps, ratings drift into "likability" scores, so weight them and keep skill separate from fair-play tags. |
| **Playo** (multi-sport, India) | Find partners by time and skill, book venues, karma points redeemable on bookings, community ratings. Revenue: commissions + subscriptions. ([1](https://builtin.com/company/playo)) | Coins redeemable on pitch discounts. A premium subscription later. |
| **Spond** (team management) | Recurring events for a season, one-tap RSVP, automatic reminders to people who haven't answered, payments tied to each fixture (who paid), line-ups, goals, player of the match. ([1](https://apps.apple.com/gb/app/spond/id755596884), [2](https://www.spond.com/news-and-blog/manage-match-fees-and-availability-in-one-app/)) | Team captains get recurring games, RSVP and auto-reminders, and a **"who paid me" checklist** for the cash share. |
| **Algerian cash-on-delivery e-commerce** | 15–40 % of COD orders are refused. Shops fight it with **confirmation calls** (target >85 % confirmed before dispatch) and **shared blacklists** of repeat refusers. ([1](https://www.egrow.com/en/blog/best-cod-software-algeria-2026), [2](https://algeriatech.news/?p=25174)) | Exactly our problem. The manager's confirmation call stays. No-show history is **shared across all venues** (it already is: one profile, one ban). |
| **Yassir** (ride-hailing, Algeria) | Mostly cash rides; the platform's commission is settled with drivers periodically rather than per ride. ([1](https://algeriatech.news/yassir-payment-institution-super-app-finance-algeria-2026/)) | Cash never passes through us. If we charge venues later, it's a monthly subscription or a monthly commission statement. |

## 2. How it works with cash

Cash means we can't hold deposits. Trust has to come from **identity +
history + social pressure + access limits**.

**Trust ladder** (enforced in SQL):

| Level | Who | Can do |
|---|---|---|
| New | Signed up, not verified | Join open games (max 2 upcoming) |
| Verified | ID checked in person by a manager | Book pitches (max 1 pending request) |
| Reliable | Verified + ≥ 5 games + reliability ≥ 90 % | Up to 3 pending requests; booking requests jump the manager's queue; may get pitches without a call |
| Banned | 2 no-shows → 7 days | Nothing new; existing games stay |

**Reliability %** = shows ÷ (shows + no-shows + late cancels), over the last
20 games. Shown on every profile and in team lists. Matchmaking prefers to put
reliable players together.

**Game-day flow:**

1. **T−24 h**: reminder to everyone. Full games can't be cancelled after this
   in the app (Playtomic rule). The booker can still call the manager.
2. **T−10 h**: "Still coming?" tap for every player. ✅ *Decided:* silence is
   **never released automatically**. At T−8 h, players who haven't answered
   are **flagged to the booker and to the stadium manager/owner**. The manager
   decides: call the player, or mark them **"not confirmed"**, which frees
   the spot for the waitlist and other players.
3. **Unfilled open game at T−10 h**: the booker and the manager are told. The
   booker chooses to play anyway, invite more people, or cancel (the slot is
   freed).
4. **Arrival**: the booker shows the QR. The manager scans it and collects the
   cash → **Guaranteed**. Individual players can check in by QR too, which
   records attendance.
5. **After**: the manager taps Complete (absent players are listed so they can
   be unticked). Players present can **report a no-show within 24 h**; the
   manager confirms it. The referee submits the report. Everyone rates.

**Paying the pitch in cash:** the booker owes the venue. The app shows each
player's share (price ÷ players) and gives the booker a **"who paid me"
checklist**, as in Spond. It's informational only: no money moves in the app.

**Cancellations** ✅ *Decided:* every cancellation counts, even days
ahead, because it always means someone isn't serious. It's recorded and
lowers the reliability % (shows ÷ (shows + no-shows + cancellations)). Inside
24 h a full game can't be cancelled in the app, so not coming = no-show.
✅ It also costs **−20 XP and −10 coins** (a no-show costs −50 / −30). A
cancellation by the manager costs the booker nothing.

**Semi-online payment without a SATIM contract** (✅ *decided: not now*,
only once the app is in production and used): many Algerians
already send money with BaridiMob/CCP transfers. A venue could accept a
transfer as an advance ("arboun"): the player uploads the receipt and the
manager confirms it. That gives Guaranteed status without card payments.
Needs your validation with real venue owners.

**Fraud we expect:**

| Abuse | Defense |
|---|---|
| Fake accounts to dodge bans | Google account + in-person ID check before booking. One ID card = one verified account: the manager types the **full card number**, stored as a keyed hash (HMAC with a server secret), so duplicates are caught without keeping readable ID numbers in the database. |
| Farming coins with fake games | Rewards only after a manager-completed game at a real venue. Daily caps per user. A venue with abnormal completion patterns is flagged. |
| A manager colluding with friends | Same caps. Admin can see per-venue stats and freeze a venue's rewards. |
| Revenge no-show reports | Only the manager can confirm a report. Players can appeal within 48 h. |

## 3. Features by role

### Player
- **Onboarding**: language, sign in, name + photo, city, positions (in order),
  self-rated level (beginner / casual / good / competitive), phone number (for
  the manager to call; checked at verification), notifications permission.
- **Home**: suggested games ("fits your usual Tuesday 21:00 in Kouba"),
  games missing players, friends playing soon, pitches nearby, sponsor slot.
- **Find a game** (Play): solo / with friends / my team, positions, city,
  day, time windows, distance, referee; searching → offer (30 s) → in.
- **Pitches**: list + **map**, filters (format, price, lights, covered,
  showers), favourites, pitch page (photos, amenities, slots, reviews,
  directions, call button).
- **Book**: slot → referee add-on → request → status ladder → QR.
- **Game page** (missing in the design): line-up on the pitch, who's coming /
  who paid, waitlist, share to WhatsApp (deep link), directions, "still
  coming?", cancel, report no-show, open the game to strangers.
- **Matches**: upcoming / past, rate, referee report view, personal stats.
- **Social**: friends (search by @handle, contacts invite), public profiles
  (rank, positions, reliability, fair-play tags, games), follow, invite
  friend (+100 coins once they play their first game).
- **Teams**: create, invite, captain, recurring weekly game, team record,
  "find an opponent".
- **Wallet**: coins, XP, rank progress, history (ledger), store (Soon).
- **Notifications center**.
- **Settings**: language, notifications, privacy (who can see my games),
  blocked users, help/report a problem, terms and privacy policy, **delete my
  account** (required by Google Play and the App Store).

### Referee
Apply (verified players only) → approved by a manager. Availability
(days/times/cities). Job list: games that asked for a referee nearby →
accept. Match report (goals, cards, MVP). Earnings list (200 DA per game,
paid in cash by the booker). Rating by players.

### Stadium manager
- **Today**: timeline, requests to confirm (call button), arrivals, scan.
- **Calendar**: week view per pitch, **block slots** (maintenance, private
  events), and **walk-in bookings** entered by hand for customers who called
  without the app. Most bookings will start this way, and it keeps the
  calendar true.
- **Pitches & prices**: pitches, formats, price per hour (peak / off-peak),
  opening hours, amenities, photos.
- **Scan**: booking QR (cash received → Guaranteed), player verification QR,
  player check-in.
- **Players**: verification queue (ID checklist), referee applications,
  no-show reports to confirm.
- **Reports**: bookings, cash expected vs received, no-shows, occupancy.
- **Staff**: invite another manager or staff member to the venue.

### BMG admin (web back-office, later)
Onboard venues and managers, disputes, freeze accounts or venues, reward
rules, sponsor/ad slots, city stats.

## 4. Screen inventory

✓ = in the prototype, ✗ = missing. Milestones are from `docs/ROADMAP.md`.

| Area | Screen | Proto | Milestone |
|---|---|---|---|
| Auth | Splash / force update | ✗ | M1 |
| Auth | Login (Google / email code) | ✓ (phone) | M1 |
| Auth | Onboarding (3 steps) | ✗ | M1 |
| Player | Home | ✓ | M2 |
| Player | Pitch list + map + filters | ✓ list only | M2 |
| Player | Pitch detail + slots | ✓ | M2 |
| Player | Book sheet / verification needed | ✓ | M2 |
| Player | Game page (line-up, RSVP, who paid, share) | ✗ | M2 |
| Player | Matches (upcoming / past) | ✓ | M2 |
| Player | Play (find a game) | ✓ | M4 |
| Player | Tag friends sheet | ✓ | M4 |
| Player | Searching / Found / You're in | ✓ | M4 |
| Player | Rate game | ✓ | M5 |
| Player | Wallet + history | ✓ (no history) | M5 |
| Player | Store (Soon) | ✓ teaser | later |
| Player | My profile + edit | ✓ view only | M1 |
| Player | Public profile | ✗ | M3 |
| Player | Friends / search / invite | ✗ | M3 |
| Player | Teams: list, create, team page | ✗ | M4 |
| Player | Notifications center | ✗ | M3 |
| Player | Report no-show / report player | ✗ | M3 |
| Referee | Apply / availability / jobs / earnings | ✗ | M5 |
| Referee | Match report | ✓ | M5 |
| Manager | Today | ✓ | M3 |
| Manager | Calendar (week) + block slot + walk-in booking | ✗ | M3 |
| Manager | Pitches & prices / venue profile | ✗ | M3 |
| Manager | Scan (booking, verification, check-in) | ✓ booking only | M3 |
| Manager | Players: verify, referees, no-show reports | ✓ (no reports) | M3 |
| Manager | Reports (cash, occupancy) | ✗ | M6 |
| Manager | Staff | ✗ | M6 |
| All | Settings (language, notifications, privacy, delete account, help, legal) | ✓ partial | M1 |
| All | Empty / error / offline states | ✗ | each milestone |

**About 15 screens are missing** from the design. Before building them, I
suggest we design them in Claude Design with the same style (game page,
onboarding, manager calendar, public profile, friends, teams, notifications
first).

## 5. Business model (later, ❓)

Free for players at launch. Options, in the order I'd try them: (1)
**venue subscription** for the manager tools (calendar, walk-ins, reports)
after a free period; (2) **sponsor slots** on Home and sponsored store items
(jerseys, tickets); (3) **premium player** (advanced stats, priority in
matchmaking); (4) commission on online payments once SATIM is live.

## 6. Legal checklist

- Algerian personal data law 18-07 (ANPD authority): declare the processing,
  get consent for location, and store as little as possible (we keep no ID
  photos).
- In-app account deletion (stores require it).
- Terms + privacy policy in AR/FR/EN; age 16+.

## 7. Questions for you

Answered: T−10 h flag to booker + manager (no auto-release) · every
cancellation counts · self-rated level ✅ · full ID number (hashed) ·
BaridiMob much later · discuss every feature first (`docs/FEATURES.md`).

Also answered: early cancel costs XP/coins · flexible sizes 3v3–11v11 ·
no women's games for now · standard Arabic/French (B2) + English, no Darija.
Next: the feature-by-feature review in `docs/FEATURES.md`.
