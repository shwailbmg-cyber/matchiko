# Matchiko feature catalogue (for discussion)

Everything an app in this field could do, so we decide once and cover it all.
Each feature has an ID. My suggestion for when to build it:

- **L** = at launch (needed for the app to work well)
- **V2** = soon after launch (first months)
- **Later** = once people use the app
- **Skip** = not worth it (for now)

Reply section by section with IDs, e.g. "C7 L, C12 skip, E4 change: …".
Decided items are marked ✅.

---

## A. Accounts and identity

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| A1 | Sign-in | Google, email code, **and phone number code** ✅ (phone code sent by WhatsApp first, SMS as fallback, through Supabase's Send SMS hook; SMS to Algeria costs ~$0.20–0.30 each) | L |
| A2 | Onboarding | Name, photo, city, positions in order, **self-rated level** ✅, phone | L |
| A3 | One account, several roles | Same account can be player + referee; a manager account is separate (decided earlier) | L |
| A4 | Verification | Manager checks ID in person; **full ID number stored as a keyed hash** ✅ to block duplicate accounts | L |
| A5 | Age rule | **15+** ✅, checked at verification | L |
| A6 | Privacy | Choose who sees my games (everyone / friends) | V2 |
| A7 | Block a user | Never matched with them, can't invite you | V2 |
| A8 | Delete account | Required by Google Play / App Store | L |
| A9 | Change phone / email | ✅ A code is sent to the new phone/email, confirm it, done. No manager check | V2 |

## B. Finding pitches and games

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| B1 | Home feed | Games that need players near you (with one-tap Join), friends playing, pitches nearby. ✅ Plus a **push to nearby players** (right position, level, reliability) when a game needs players | L |
| B2 | "Suggested for you" ✅ | **Recommender system**: learns from your usual days, times, pitches, friends, positions and level; starts with simple scoring, then improves with data | V2 |
| B3 | Pitch list + filters | Format, price, lights, covered, showers, distance | L |
| B4 | Map view ✅ | Pitches on a map (OpenStreetMap = free) | V2 |
| B5 | Pitch page | Photos, amenities, prices, slots, reviews, call, directions (opens Google Maps) | L |
| B6 | Favourite pitches | Quick access + alerts when a slot frees up | V2 |
| B7 | Free-slot alert | "Tell me if Kouba Five frees up Tuesday 21:00" | V2 |
| B8 | **69 wilayas + communes** ✅ | All 69 wilayas (11 new ones in 2025–26) and their 1,541 communes, so pitches in small towns are covered; search in another wilaya when travelling | L |

## C. Games (the heart)

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| C1 | Private game | Booker books, invites friends | L |
| C2 | Open game | Booker opens free spots to strangers ("Games missing players") | L |
| C3 | Invite by WhatsApp link | Link opens the game in the app (or the store if not installed) | L |
| C4 | Game page | Line-up on the pitch, who's coming, who paid, waitlist, directions | L |
| C5 | Guest players (no app) | Booker adds "Karim (guest)" so the line-up is full; guests get no rewards | L |
| C6 | Waitlist | Full game → join the waitlist; first in gets the freed spot | L |
| C7 | "Still coming?" at **T−10 h** ✅ | No answer → **flagged to booker + manager**, the manager calls or marks "not confirmed", which frees the spot ✅ | L |
| C8 | **Find a replacement** | When someone cancels, the spot is pushed to nearby players with the same position and good reliability | V2 |
| C9 | Cancel | Every cancellation counts ✅: lowers reliability **and costs −20 XP / −10 coins** ✅ (manager cancellations cost nothing). Inside 24 h of a full game, no app cancel → absence = no-show | L ✅ built |
| C10 | Recurring weekly game | "Every Tuesday 21:00 at Kouba", same group, auto-invite | V2 |
| C11 | Auto-balanced teams | By level/rank, friends together ✅; booker can swap players | L |
| C12 | Bibs/colours | "Team A = bibs" note on the game page | V2 |
| C13 | Game chat | WhatsApp group link at launch; in-app chat later | L (link) / Later (chat) |
| C14 | Flexible sizes ✅ | A pitch has a max size (7-a-side, full 11-a-side…); the booker picks any size from 3v3 up to that max (5v5, 6v6, 7v7, 8v8, 11v11…) and can change it before the game | L ✅ built |
| C15 | Women's / mixed games | ✅ Not for now | Skip |
| C16 | Level of a game | "Casual / competitive" tag so beginners don't land in strong games | L |

## D. Matchmaking (smart search)

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| D1 | Modes | Solo / with friends / my team ✅ | L |
| D2 | Criteria | Positions in order, city, day, time windows, distance, referee ✅ | L |
| D3 | Join existing open games first | Score by position, time, distance, level, reliability | L |
| D4 | Pooling | Enough searchers in an area → the app proposes a new game at a free pitch | V2 |
| D5 | 30 s offer | Accept or pass ✅ | L |
| D6 | Reliable with reliable | Players under 80 % reliability are matched last | L |
| D7 | Team vs team challenge | My team looks for an opponent of similar level ✅ | L |
| D8 | "Ping me any time" | Anytime alerts for games nearby (prototype toggle) | L |

## E. Stadium manager / owner

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| E1 | Today timeline | Requests to confirm (call button), arrivals, scan | L |
| E2 | Confirm by phone | Call → Confirm ✅ | L |
| E3 | Week calendar | All pitches, all bookings, free slots | L |
| E4 | **Walk-in bookings** | See box below | L |
| E5 | Block slots | Maintenance, private events, school use | L |
| E6 | Weekly "abonnement" | A team books the same slot every week for a month/season | L |
| E7 | Prices | Per pitch, peak/off-peak, weekend, Ramadan nights, **student and off-peak prices** ✅ | L |
| E8 | Opening hours | Per day, special days (Eid, Ramadan) | L |
| E9 | Scan QR | Booking (cash received → Guaranteed), player verification, player check-in ✅ | L |
| E10 | No-show / "not confirmed" | Mark players; it frees the spot ✅ | L |
| E11 | Cash day close | End of day: expected vs received, per staff member | V2 |
| E12 | Venue blacklist | Ban a player from this venue only | V2 |
| E13 | Staff accounts | Owner + staff with limited rights (staff can scan, not change prices) | V2 |
| E14 | Venue profile | Photos, amenities, rules, map pin | L |
| E15 | Reports | Occupancy, revenue (cash recorded), no-shows | V2 |
| E16 | Equipment loan with deposit ✅ | The venue lends bibs and a ball; the booker leaves a small cash deposit (e.g. 500 DA or his ID card), returned when the equipment comes back. The app records who has what | V2 |
| E17 | Venue tournaments | Venue creates a tournament, teams register | Later |
| E18 | **Last-minute deals** ✅ | A slot still empty 3 h before gets a discount set by the manager, pushed to nearby players | V2 |
| E19 | **Training / beginner sessions** ✅ | Venues or coaches list paid sessions (beginners, kids 15+, goalkeepers); players book a place. Also a Premium perk | Later |

**E4 Walk-in bookings, explained.** Most people will keep booking by phone
call or in person at first, without the app. If the manager doesn't enter
those bookings, the app shows the slot as **free** when it's actually taken,
and an app user books it → double booking → angry customers. So the manager
gets a quick "+ Booking" button: name, phone, time, pitch. The slot is then
taken in the app too. It also makes the app the manager's **only calendar**
(replacing his notebook), which is what makes managers keep using it.

## F. Trust and safety

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| F1 | Reliability % | Shows ÷ (shows + no-shows + cancellations), last 20 games ✅ | L |
| F2 | Trust ladder | New → Verified → Reliable → Banned, with booking limits | L |
| F3 | No-show penalty | −50 XP, −30 coins; 2 → 7-day ban ✅ | L |
| F4 | Report a no-show | Players present report within 24 h, the manager confirms | L |
| F5 | Appeal | Player can contest within 48 h; admin decides | V2 |
| F6 | Report a player | Violence, insults, cheating → admin review, suspension | L |
| F7 | Fair-play tags | #fair_play, #on_time, #late… on profiles ✅ | L |
| F8 | Rating weight | Ratings from reliable, verified players count more; can't rate the same person twice a week | L |
| F9 | Fraud checks | Daily reward caps, flag odd venues/patterns | V2 |

## G. Referees

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| G1 | Apply + approval | Verified player applies, a manager approves ✅ | L |
| G2 | Availability | Days, hours, cities | V2 |
| G3 | Job board | Games that asked for a referee nearby; first to accept gets it | V2 |
| G4 | Manager assigns | Manager picks a referee from his venue's list | L |
| G5 | Match report | Goals, cards, MVP ✅ | L |
| G6 | Earnings | 200 DA per game paid cash by the booker ✅; history list | V2 |
| G7 | Referee rating | Players rate the referee | V2 |

## H. After the game

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| H1 | Score + result | From the referee, or the booker enters it if no referee | L |
| H2 | MVP vote | Players vote when there's no referee | L |
| H3 | Rate players + pitch | Stars + tags ✅ | L |
| H4 | Personal stats | Games, wins, goals, MVPs, positions played, favourite pitch | L |
| H5 | Match photos | Upload a team photo | Later |

## I. Rewards and motivation

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| I1 | XP + ranks | Tuned by simulation ✅ (`docs/economy/REWARDS.md`) | L |
| I2 | Coins + wallet + history | ✅ | L |
| I3 | Badges | First game, 10/50/100 games, hat-trick, iron man (4 weeks in a row), referee 10 games | V2 |
| I4 | Weekly streak | Play at least once a week → streak flame | V2 |
| I5 | Leaderboards | City / pitch / friends, monthly | V2 |
| I6 | Store | Pitch discount, tickets, jerseys, community, frames, free referee ✅ (prices to set) | Later |
| I7 | Invite a friend | +100 coins when the friend plays his first game ✅ | L |
| I8 | Seasons | Ranks never reset; leaderboards reset monthly | V2 |

## J. Social and community

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| J1 | Friends | Search @handle, add from contacts, accept | L |
| J2 | Public profile | Rank, positions, reliability, tags, stats | L |
| J3 | Teams | Create, invite, captain, record ✅ | L |
| J4 | Team page | Members, next games, record, recurring slot | V2 |
| J5 | Team challenges | Challenge another team, accept, book | V2 |
| J6 | Leagues | Season league between teams at one venue | Later |
| J7 | Communities | Neighbourhood / company / university groups | Later |
| J8 | Activity feed | "Yacine scored a hat-trick" | Skip |

## K. Communication

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| K1 | Push notifications | Confirmed, reminders, T−10 h, waitlist spot, offers | L |
| K2 | Notifications center | In-app list | L |
| K3 | WhatsApp share | Game invite, result card image | L |
| K4 | In-app chat | Game/team chat | Later |
| K5 | Quiet hours | No push at night except game-day | V2 |

## L. Money

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| L1 | Cash at the pitch | QR scan → Guaranteed ✅ | L |
| L2 | Share per player ✅ | Shown in **round DA amounts, multiples of 50** (50, 100, 150…). If price ÷ all players isn't a multiple of 50, **goalkeepers don't pay** and the rest share it. If it still isn't round, round to the nearest 50 ✅ (e.g. 208 → 200; the booker pays the missing 100 DA himself). The difference is shown to the booker | L ✅ built (calculation) |
| L3 | "Who paid me" | Booker ticks who paid his share | L |
| L4 | BaridiMob receipt advance | ✅ much later | Later |
| L5 | SATIM card payment | ✅ later | Later |

## M. Business (how BMG.dev earns) ✅

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| M1 | Free for players | Players never pay to use the app ✅ | L |
| M2 | Venue plan A: **10 % commission** | 10 % of each game booked through the app. The manager pays nothing else. Cash is never handled by us: a **monthly statement** of app bookings, paid by the venue ✅ | L |
| M3 | Venue plan B: **monthly subscription** | Fixed monthly fee, no commission. The venue picks A or B ✅ | L |
| M4 | Sponsors | Sponsored tournaments, store items, jerseys ✅ | Later |
| M5 | **Premium player** | Paid plan with real perks: T-shirts, training sessions, invitations to special games/events, priority in matching, advanced stats ✅ | Later |
| M6 | Small sponsor ads | Small ad slots (home, game page, results card) ✅ | Later |
| M7 | Commission on online payments | When SATIM is live | Later |

**Commission note.** Walk-in bookings the manager enters himself are not
charged (only bookings made by players in the app), so managers have no
reason to hide bookings. The risk is a player and manager agreeing to book
outside the app: the trust ladder, rewards and verification only work for
in-app bookings, which keeps players inside.

## N. BMG admin back-office (web)

| ID | Feature | Suggest |
|---|---|---|
| N1 | Add venues and managers | L (a simple admin page, or Supabase dashboard at first) |
| N2 | Reports and appeals | V2 |
| N3 | Suspend users / venues | L |
| N4 | Edit reward rules, cities, prices | L (SQL/dashboard at first) |
| N5 | Stats (users, games, no-show rate per city) | V2 |
| N6 | Broadcast push (announcements) | V2 |

## O. Algeria-specific

| ID | Feature | How it works | Suggest |
|---|---|---|---|
| O1 | Weekend = Friday–Saturday | Suggestions, peak prices, calendars use it | L |
| O2 | Ramadan mode | Time windows shift after iftar / taraweeh (22:00–02:00), Ramadan prices | L |
| O3 | Summer heat | Default suggestions favour evening/night in summer | V2 |
| O4 | Prayer times | Avoid suggesting Friday 12:00–14:00 | V2 |
| O5 | Language level ✅ | **Standard Arabic and standard French, simple (B2 level max), plus English** for the younger generation. No Darija. The app opens in the phone's language (EN/FR/AR), English otherwise | L ✅ |
| O6 | Low connectivity | Works on 3G, caches the last screens, small images | L |
| O7 | Low-end phones | Light animations, small app size | L |

## P. Quality and operations

| ID | Feature | Suggest |
|---|---|---|
| P1 | Crash reporting (Sentry free tier) | L |
| P2 | Privacy-friendly analytics (PostHog free tier) | L |
| P3 | Force update when a version is too old | L |
| P4 | Terms + privacy (AR/FR/EN), law 18-07 | L |
| P5 | Accessibility (text size, contrast) | L |
| P6 | Light theme | Skip (dark only, as designed) |

---

## Next to discuss

Go through the sections and reply with IDs. Suggested order: **C** (games),
**E** (manager), **F** (trust), then the rest.
