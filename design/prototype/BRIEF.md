# Matchiko — project brief & handoff

Read this first in every new chat. Main file: `Matchiko.html` (mobile prototype, 390×844 phone frame).

## Product
Matchiko is an app for organising small football games (5v5 / 6v6 / 8v8) in Algeria. It fixes the everyday problem of getting enough players, finding a free pitch, and stopping no-shows in a mostly-cash market. The key feature is **smart matchmaking and suggestions**. Principles: KISS, fast, simple, scalable, ready for ads, sponsors and marketing later.

Roles (separate login role; a manager sees only the manager UI):
- **Player**: finds or joins games, books pitches, can referee.
- **Referee**: a verified player approved by a stadium manager. Costs 200 DA per game, paid by the booker. Logs goals, cards and MVP.
- **Stadium manager**: confirms bookings after the phone call, verifies player identity (ID card name and photo vs. profile), scans booking QR codes, approves referees.

## Locked decisions (from the user's forms)
- **Find game modes**: Solo / With friends (@tag friends → same team) / My team (whole team looks for an opponent).
- A search can include **multiple positions** (ordered by preference) and a **city** (the player may travel, e.g. Alger today, Oran tomorrow), plus day, time windows, distance, and an optional referee.
- **Team split**: balanced by rank, with tagged friends kept together.
- **Game status**: Requested (sent) → Confirmed (manager took the call) → Guaranteed (full amount paid: cash scanned by QR at the pitch, OR online via SATIM with CIB/Edahabia).
- **Verification**: done by the stadium manager in person (ID vs. profile name and photo). Unverified players can **join games only**; booking a pitch requires verification. Shown as a Verified badge.
- **Two numbers**: Rank XP (sets the tier, can't be spent) + Coins (wallet, spent in the future store).
- **Coins earned by**: showing up to a booked game +20, rating a game +10, refereeing +50, win/goal/MVP +30, paying online +15, inviting a friend +100, getting verified +200.
- **No-show**: −50 XP and −30 coins; 2 no-shows = 7-day booking ban.
- **Ratings after a game**: stars per player + tags (#fair_play, #on_time, #late…), plus a pitch rating.
- **Store (teaser, "Soon")**: pitch discount, tournament tickets, sponsor jerseys, community access, profile frames, free referee.
- **Ranks**: 🥉 Bronze 0 · 🥈 Silver 500 · 🥇 Gold 1000 · 💎 Elite 2000 · 👑 Legend 3500 XP.
- **Positions**: 🧤 GK · 🛡️ DEF · 🎯 MID · ⚽ FWD · 🟨 REF (emoji badges).
- **Languages**: EN / FR / AR, switchable in Settings and on Login; Arabic = full RTL.

## Design system
- Dark pitch green with Algerian zellij accents (8-point khatam star pattern, sand-gold lines).
- Colors: bg #06110b, card #0e2016, card2 #15301f, text #eaf5ee, sub #9dbfa9, brand #1a6b3c, lime accent #3ddc84 (ink #04200f), sand #e9c46a, terra #ef7b5a (opponents), red #f06464.
- Type: Barlow Condensed (display, numbers, uppercase headlines) + Cairo (body, Arabic).
- Logo: zellij 8-point star (two rotated squares) with a pentagon "ball" in the center, next to the wordmark "matchi**ko**".
- Components: 56px lime CTA, 17px radius; cards with 18px radius and a thin line border; bottom sheets; the center Play nav button is a rotated diamond; pitch visuals are drawn with stripes and line markings (placeholders; real photos to come).

## Code architecture (vanilla JS, no React/Babel — React via Babel failed to load earlier)
Script load order in Matchiko.html: i18n → i18n2 → i18n3 → core → screens-a → screens-b → play → pay → games → wallet → manager → app.
- `matchiko-i18n.js`, `-i18n2.js` (player v2), `-i18n3.js` (manager): `I18N.en/fr/ar` string maps; `t(key,{vars})`.
- `matchiko-core.js`: state `S` (persisted to localStorage key `matchiko_v2` via the `KEEP` list + `save()`), the `ACT` registry, icons `ic()`, `logoMark()`, `av()`, `qr()`, `pitchLines()`, data (ST pitches, FRIENDS, MYTEAMS, CITIES, OPEN games), `teams()` balancing, `POS_E`, `RANKS`, `rankOf`, `posBadge`, `rankBadge`, `verBadge`.
- Screens are functions `SC.name = () => htmlString`. Clicks use `data-act="x" data-arg="y"` → `ACT.x(arg)`. `go(screen)` navigates; `render(1)` re-renders and keeps the scroll position.
- `screens-a`: home, detail (pitch + slots). `screens-b`: searching (radar), found (30s accept + pitch + teams), confirmed ticket, ticket(). Old matches/profile/settings in this file are overridden by later files.
- `play.js`: Play screen (modes, tag-friends sheet, city, multi-position, referee toggle).
- `pay.js`: booking sheet (referee add-on, cash vs. SATIM), verification-needed sheet, SATIM payment screen, status ladder `ladder()` and `stTag()`.
- `games.js`: Matches (upcoming with status + QR; past with rating), rate screen (pitch + per-player stars/tags), reflog (referee match report).
- `wallet.js`: wallet (coins, XP, earn list, store teaser, no-show rule), profile (rank progress, badges, verified, demo toggle for the verified flag), settings.
- `manager.js`: login (phone + role pick), mtoday (timeline + confirm), mscan (QR viewfinder → cash received → Guaranteed), mplayers (ID verification checklist + referee requests).
- `app.js`: nav, render/go, timers (searching, found countdown), core ACT handlers, live counter, fit-to-screen scaling.

## Status
Working: all 17 screens and 6 sheets checked; no console errors.

## Next ideas (not built)
- Suggestions engine UI ("Suggested for you": games that fit your usual times, city and friends; push "your friend is playing tonight").
- Team management (create team, invite by @handle, captain tools).
- Referee profile and availability, referee rating by players.
- Manager: weekly calendar, pricing per slot, no-show reporting, earnings.
- Notifications center, communities/events, sponsor ad slots, and store purchase flow.
- Real pitch photos (the user will provide them).

## User preferences
Concise answers. Keep the user's text verbatim. Keep KISS and scalability in mind.
