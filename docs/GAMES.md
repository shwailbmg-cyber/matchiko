# Game organising: every scenario, challenges and sharing

How people get a game in Matchiko, whoever they are: alone, with friends,
with a team, with or without an opponent. Then the competition layer
(challenges, titles, rankings) and sharing to social media.

Based on research of similar apps worldwide (§ 1; sources in
`COMPETITORS.md`), on what their users complain about and ask for, and on
your ideas. Your decisions are in § 9, the words used in § 10. Releases R1 / R2 / R3 as in
`BLUEPRINT.md`.

---

## 1. What the research says

How it was done: three web research passes (November 2026). Most review
and developer pages could not be opened directly from this session, so the
findings come from search results of those pages. Treat numbers as
"reported".

### What users complain about (most frequent first)

1. **Cancellation and refund rules** that feel unfair (CeleBreak, GoodRec,
   Malaeb, Footy Addicts). → Our cash model has no refunds to fight about;
   keep rules few and visible.
2. **No-shows and late dropouts**; games short by 2–3 players every week
   (Footy Addicts, Playo, Fubles, Playtomic). Powerleague says 84 % of
   5-a-side teams have same-day dropouts.
3. **Skill mismatch and unfair levels**: beginners in strong games, peer
   ratings that are biased, a level that drops with no way to contest
   (GoodRec, Plei, Playtomic).
4. **Organisers and venues that are unreliable**: host cancels without a
   reason, venue says the slot was not free (Yalla Hagz, Egypt).
5. Payment and app bugs · 6. No human support · 7. **Toxic or dangerous
   play** · 8. Overbooked games · 9. Notification noise · 10. Too few
   players outside big cities.

### What users ask for

Player ratings · games by level · one or two "free passes" for a late
cancel when ill · rewards · add to calendar · instant alert when a spot
opens · friends features · stats after the game · reviews only the
organiser sees · paying only your own share.

### What they like

Finding a game the same day with no commitment · friendly, well-run games ·
nothing to sort out at the pitch · a host who brings bibs, balances the
teams and moves players who are at the wrong level.

### What WhatsApp organisers suffer from

A 👍 can mean "in" or "maybe"; answers get buried; the organiser chases
money and pays the gap when 7 come instead of 10; a group needs 25–30
people to field a 5-a-side; the group dies when the organiser gets tired.
They want: clear in/out, automatic waitlist, who owes what, reliability
history, a reserve pool.

### Ideas worth taking (and from whom)

| Idea | From |
|---|---|
| Friendly vs ranked chosen at creation; only ranked moves ratings | Playtomic |
| Level band on a game; players outside it "ask to join" | Playtomic, Playo |
| Team availability board: "we are free Thursday 20:00", others challenge | FiveKick (Belgium) |
| One "Looking for" board: opponent, player, team, pitch, referee | CricHeroes (India), OLE (UAE) |
| Fill-in player posts with clear money terms (free / team pays / pays his share) | BenchApp |
| Goalkeeper for hire, rated on punctuality and behaviour | Goleiro de Aluguel (Brazil) |
| Score entered by one captain, confirmed by the other | FiveKick |
| Balanced teams with win probability shown; a manual swap shows its effect | Atmos Football |
| A title for showing up most on a pitch in the last 90 days | Strava "Local Legend" |
| A short challenge to re-check your level | Playtomic "10-match challenge" |
| Level set by a few situation questions, not a bare self-rating | Poteau (France) |
| Peer awards after the game beyond MVP | Appito (Brazil), Tonsser |
| Solo players merged into teams for a league season | Volo, Urban Rec, CeleBreak, Leisure Leagues |
| Stat stickers over your own photo for Stories | Strava, Nike Run Club |

**Important:** building a team of solo players **on demand, for one
match, against an existing team** was not found in any app. Only league
operators do it, once, at season registration. Your idea (§ 3, T3) would
be new.

**Algeria:** an app called **Matchna** exists (pay at the venue or by
card, QR check-in) and **FieldZ** announces an app. `COMPETITORS.md` said
there was no Algerian app: corrected.

---

## 2. Building blocks

Seven simple things. Every scenario is a combination of them.

| Block | What it is |
|---|---|
| **Game** | One hour on a pitch, two sides, a size (3v3 … 11v11). **Friendly** or **Ranked**, chosen at creation and locked. Has exactly one **booker** (verified), the person the manager calls. |
| **Group** | Me + friends I tagged, for one search. Friends accept with one tap. A group always lands on the **same side**. |
| **Team** | Permanent: name, colours, crest (generated, no real club logos), captain + co-captain, up to 25 members, home commune, usual size, a rating. |
| **Call-up** | The captain asks his team "Thursday 21:00, are you in?". Only **In** or **Out** (no "maybe"). Automatic reminders to those who did not answer. |
| **Loan player** | A player who fills an empty spot in a team for one game (called "Joker" in earlier drafts). |
| **Selection** | A one-game team built by the app from solo players and groups, to face a real team. Its name is chosen by its captain or given by the app. |
| **Transfer market** (the Board) | One feed per wilaya/commune of everything that is "looking for": game needs players · team needs a loan player · team seeks an opponent · game needs a referee · team recruits members. |

**Friendly / Ranked.** Friendly: rewards for showing up, nothing else
moves. Ranked: the result moves the team rating and the players' level.
Ranked needs a confirmed result (§ 4.3) and **verified players only** ✅. This is the
answer to "too competitive / toxic" complaints: people choose.

**Who pays (cash).** ✅ Decided: money stays **offline and is agreed
between the players**. The app does not force a way to pay.

- The app shows a **suggested share per player** (price ÷ players, in
  50 DA steps as today) and the optional "who paid" list. Usually each
  player pays his part.
- Who plays free (a keeper, a loan player) is agreed by the people involved.
  The organiser can write it in the post ("keeper plays free").
- **One fixed rule:** a player who joins alone a game **organised by the
  app** (a Selection, a game built from waiting players) **pays his own
  share**.
- The venue still gets the full price: the manager scans the booking QR
  when the cash is in, as today.

---

## 3. Every scenario

Each line: the situation → what the user does → what the app does →
what happens if it does not work.

### Alone

| # | Situation | Flow | If it fails |
|---|---|---|---|
| S1 | I want to play soon | Play → positions, day, time, distance → Search | Offer of an open game (30 s). No game → new game built from waiting players (BLUEPRINT § 5.5). Still nothing → "Tell me when a game appears" + other days or communes proposed |
| S2 | I browse open games | Home / Transfer market → Join | Game full → waitlist. Ranked game outside my level → "Ask to join", the booker says yes or no |
| S3 | A team needs one more player | Transfer market → "FC Kouba needs a defender, Thu 21:00, you pay your share" → Take the spot | Captain accepts (or automatic if my reliability ≥ 90 %). Not accepted in 2 h → released |
| S4 | **I want to play against a real team but I have no team** | Play → "Face a team" → I pick a team's open challenge from the list, or "any" | I join that game's **Selection** side. Selection not full in time → see T3 fallbacks |
| S5 | I am a goalkeeper | "Keeper" mode in Play: I get keeper requests first | Keepers are always wanted and get a coin bonus (§ 5.4). Whether the keeper pays is agreed offline, like all money |
| S6 | I want to join a team for good | Transfer market → "Teams recruiting" → Apply | Captain accepts or not. Good loan players get invited by teams |
| S7 | I am new, not verified | I can join games and Selection sides (max 2 upcoming) | I cannot book, captain a team, or play Ranked until verified |
| S8 | I must cancel | Leave game | Normal cost (−20 XP / −10 coins) unless I use a **free pass** (§ 5.5). My spot goes to the waitlist, then to nearby players |

### With friends

| # | Situation | Flow | If it fails |
|---|---|---|---|
| F1 | **I want to play with a friend** | Play → With friends → tag @friend → he gets a push → **Accept** → search starts for the group | We always land on the same side |
| F2 | A friend does not answer | After 15 min (or when I tap "Start with those who accepted") the search starts without him | He can still join later from the game link if a spot is left on our side |
| F3 | A friend refuses or leaves the group | He is removed; the search continues | — |
| F4 | A friend is not on the app | I send him the invite link (WhatsApp); he installs and lands in my group | Or I add him as a **guest** (no rewards for him; I answer for him) |
| F5 | We are too many for any open game (6 friends, games are 5v5) | The app proposes: "Make your own game" → we become one side and look for an opponent (F6) | Or split in two groups |
| F6 | We are a group and want a match against others | "One-day team": the app names it ("Yacine's team"); we look for an opponent like a team does (T2/T3), Friendly | After 2 games together the app offers "Save as a team" |
| F7 | We want to play against each other | Private game → **Draft mode**: two captains pick players in turn, like at school | Or "Balance for me" (automatic, with win probability shown) |
| F8 | A friend cancels after the game is found | His spot goes to waitlist / nearby players; the rest of the group stays | — |
| F9 | I tag someone banned, blocked or already playing at that time | The app says he cannot be tagged for this game | — |

### With a team

| # | Situation | Flow | If it fails |
|---|---|---|---|
| T1 | **We want to play a team we know** | Team page → Challenge → Friendly/Ranked, size, 1–3 proposed slots (or "you choose") | Other captain: accept one slot, propose another, or refuse. No answer in 48 h → expired |
| T2 | **We want a game but have no opponent** | Team → Find opponent → size, days, times, commune/wilaya, Friendly/Ranked | Posted on the Transfer market + matched with other teams searching (close rating first; the gap allowed grows with time) |
| T3 | **No team is available** | Automatic, or the captain picks "any opponent" from the start | **The app builds a Selection** (§ 3.1). If the Selection is not full 12 h before: play smaller (5v5 instead of 7v7) · lend 1–2 of our players to the Selection · turn it into a normal open game (both sides mixed) · cancel free of cost |
| T4 | **We are short of players** | Call-up shows 5 In of 7 → captain taps "Find loan players": position, level, terms (free / pays his share / team pays) | Transfer market + push to nearby players, keepers first. Players who were good loan players before are asked first ("friends of the team") |
| T5 | We are too many | Extra players are substitutes; everyone present shares the price | Captain sets who starts |
| T6 | We already booked a pitch | The challenge shows "pitch booked ✓": the opponent only has to accept | — |
| T7 | Two teams matched but no pitch is free then | The app proposes the nearest other hour or pitch; both captains accept | Else the match is dropped, no cost |
| T8 | **The opponent withdraws late** (< 24 h) | The withdrawing team loses team reliability; its captain pays the cancel cost | The app at once asks searching teams ("last-minute opponent wanted", bonus coins), then builds a Selection, then offers T3 fallbacks |
| T9 | After the game | One captain enters the score, the other confirms; silence for 24 h = confirmed | Disagreement → no rating change; repeated disputes are flagged to an admin |
| T10 | Rematch | "Rematch" button → same slot next week proposed | Head-to-head record kept ("FC Kouba 3 – 2 Hydra Stars") |
| T11 | Training among ourselves | Team → Internal game → Draft mode or automatic balance | Missing players → loan players |
| T12 | Captain is away | Co-captain can do everything; captain can hand over the role | — |
| T13 | Very different levels | Allowed as Friendly; Ranked moves the rating only a little | — |
| T14 | Away game in another wilaya | Search or challenge in that wilaya | — |

### Booker and venue

| # | Situation | Flow |
|---|---|---|
| B1 | Private game with friends | Book → invite → who paid me (as today) |
| B2 | I am missing 3 players | "Open to others": the game appears on Home, the Transfer market and in searches |
| B3 | Same game every week | Recurring game: next week's request is created automatically |
| V1 | The venue runs its own open game ("house game", e.g. every Friday 17:00) | The manager is the host; players join; each pays his share at the venue. Fills empty hours, gives beginners a safe entry |
| V2 | A slot is still empty 3 h before | Last-minute deal pushed to nearby players |
| V3 | The venue wants life around its pitch | Title holder (§ 4.5), evening cups (§ 4.8) |

### Things that go wrong (all game types)

| Problem | Rule |
|---|---|
| Too few players 10 h before | Booker/captains choose: play smaller, open to others, or cancel. Cancelled by the system for lack of players = no cost to anyone |
| Odd numbers (9 players) | Sides of 5 and 4; the stronger players go to the smaller side |
| Pitch closed, rain, power cut | Manager cancels → no cost; the app offers to rebook |
| Late arrival | Default: 15 minutes of grace; then tagged "late"; after 30 minutes = no-show. Both numbers are server settings, to adjust after real games |
| Injury or real emergency | The booker or the manager can excuse a player (no penalty), at most once a month per player |
| Booker cancels a game strangers joined | He pays the cancel cost; the others are told at once and searched again first in line |
| No referee came | The game is played; result by captains/booker (§ 4.3) |
| Blocked players | Never placed in the same game, group or Selection |
| Someone plays rough | Report → admin; the booker/host can remove a player before the game; fair-play tags after it |

### 3.1 Selection: how the app builds an opponent

1. **Opened by:** a team (or one-day team) with no opponent (T2/T3), or
   a solo who taps "Face a team" (S4).
2. **Who can join:** solos and groups with reliability ≥ 80 %, inside the
   level band of the team (± 1 level). Not blocked by anyone in it.
3. **How it fills:** the same matching score as everywhere (position,
   time, distance, level). One keeper first (keeper requests go out
   first). One extra **standby** player is taken when possible, because
   strangers drop out more.
4. **Captain of the Selection:** the first verified, reliable player who
   accepts the role. He confirms the score after the game and gets a
   host bonus (§ 5.4).
5. **Identity:** a temporary name ("Sélection Kouba") and a bib colour.
6. **Clock:** shown on the Transfer market with a counter ("4 / 7"). Confirmed when
   full; checked at T−12 h (fallbacks in T3); "Still coming?" at T−10 h
   like every game.
7. **Rating:** a Selection has a rating computed from its players' levels.
   A Ranked game against a Selection moves the team's rating at half
   strength.
8. **Growth loop:** players who win or play together in Selections 3 times
   get "You play well together. Create a team?".

Version 1 (R1) is simple: the team's game is published with **side B
open to anyone**, and players join it by hand from the Transfer market. Version 2
(R2) adds the automatic search, standby and fallbacks.

---

## 4. Challenges and competition

### 4.1 Levels (players)

- Onboarding asks **4 short situation questions** instead of a bare
  "your level?" (played in a club? how often? …) → a starting level.
- Level is shown as 1.0–5.0 with "provisional" until 5 ranked games.
- Ranked results move it (beating stronger players moves it more); skill
  stars from other players adjust it slowly (weights in BLUEPRINT § 6.5).
- **Level check:** a player who thinks his level is wrong starts a
  5-game check; during it his level moves faster.
- Friendly games never change the level.

### 4.2 Team rating and divisions

- Team rating (Elo): starts at 1000; moves fast for the first 5 ranked
  games, then normally; half strength against a Selection.
- Shown as a **division** per wilaya (Division 3 → 2 → 1 → Elite).
- **Team reliability %**: games played ÷ (played + withdrawn late).
  Teams under 80 % are matched last.

### 4.3 Results

Ranked game: referee report, or one captain enters and the other
confirms. No referee and no captains (open game): the booker enters,
players confirm with one tap (≥ 50 %). Disputed = nothing moves.

### 4.4 The challenge board

Teams post when they are free ("Thursday 20:00–22:00, 7v7, Bab Ezzouar");
other teams answer with one tap. Solo players see the same posts with
"Face them" (joins the Selection). Filters: day, size, level, commune.

### 4.5 Title holder

Each venue has one title per game size. The first team to win a Ranked
game there holds it. Any team can challenge the holder at that venue; the
holder must accept a challenge within **14 days** or the title becomes
free. Each win is a "defence" counted on the team page and the venue
page. The venue can add a prize (a free hour). Good for venues: it sells
hours.

### 4.6 Pillar of the pitch

For players: the one who **played the most games** on a pitch in the
last 90 days (not the best, the most present) gets the title on the pitch
page. It moves when someone plays more. Rewards showing up, which is what
the whole app needs.

### 4.7 Personal challenges

- **Weekly missions** (3 small ones, changed each week): play one game ·
  play with someone new · rate your game · play as keeper · try a new
  pitch. Each gives a few coins; all three gives a bonus.
- **Duel with a friend:** "Who plays more games this month?" or "who
  scores more?" Up to 10 friends. The winner gets a badge, no coins
  (no reason to cheat).
- **Awards after each game** (players vote, one vote each): MVP, best
  keeper, fair play.

### 4.8 Cups and seasons (R3)

- **Evening cup:** a venue creates a 4- or 8-team knockout in one
  evening (Ramadan nights). Teams register; **solo players register too
  and the app builds Selection teams** for them.
- **Monthly table per wilaya:** 3 points a win, 1 a draw, ranked games
  only, at least 2 games to appear. Resets each month; ratings do not.
- **Commune derby:** once a month, two neighbouring communes; every
  ranked win by a team of a commune counts for it.

### 4.9 Fair matches

When sides are drawn the app shows the **chance of each side winning**;
if the booker swaps players he sees the number change. A game above
65 / 35 shows "unbalanced".

---

## 5. Changes to rewards (adds to BLUEPRINT § 6)

5.1 Friendly and Ranked games give the same XP/coins for showing up.
Win / goal / MVP rewards only in games with a confirmed result.

5.2 **Team game extras:** winning a ranked team game +10 XP for each
player; a title defence +20 XP.

5.3 **Missions:** 5–10 coins each, +20 for all three in a week.

5.4 **Roles people avoid get paid more:** keeper in a Selection or as a
loan player +20 coins; host or Selection captain of a completed open game
+20 coins; loan player who shows up +10 coins.

5.5 **Free pass** ✅: every 10 games played without a cancel or no-show
earns one pass (max 2 kept). A pass cancels the cost of one cancellation
made more than 3 hours before kick-off. It answers the top user wish
("I was ill") without weakening the rule for unreliable players.

5.6 Sharing gives **no coins** (it would create spam). What is rewarded
is the result: a friend who signs up, gets verified and plays (invite
reward, already decided).

---

## 6. Sharing to social media

### 6.1 What can be shared (cards made by the app)

| # | Card | When | Carries |
|---|---|---|---|
| 1 | **Game invite** "2 spots left · Kouba Five · Thu 21:00" | Game page | Link + QR |
| 2 | **Match poster** "FC Kouba vs Hydra Stars" (crests, date, pitch) | Challenge accepted | Link |
| 3 | **Open challenge** "Who dares? FC Kouba seeks an opponent" | Team searching | Link → "Face them" |
| 4 | **Line-up** (pitch with names) | Before the game | — |
| 5 | **Result** (score, scorers, MVP) | After the game | — |
| 6 | **My player card** (level, position, games, goals, reliability, badges) | Profile | Link to my profile |
| 7 | **Award** (MVP, best keeper, fair play) | After the vote | — |
| 8 | **Rank-up / badge / streak / title** | When earned | — |
| 9 | **My month** and **my year** (games, goals, favourite pitch, best teammate) | 1st of the month, end of the year | — |
| 10 | **Team card / season** (record, division, titles) | Team page | Link → challenge us |

Formats: **9:16** for Stories/Status/Snap/TikTok, **4:5** for WhatsApp
groups and feeds. R2: a **transparent sticker** version of cards 5 and 7
to put over your own photo (the Strava / Nike pattern), and a short
video for "my year".

### 6.2 How it works technically

- The app draws the card as an image and opens the phone's **share
  sheet** (`share_plus`, verified publisher). That covers WhatsApp,
  WhatsApp Status, Snapchat, TikTok, Instagram, Facebook, Telegram, X
  with no extra SDK.
- ✅ Decided: **direct buttons for Instagram, Snapchat and TikTok** too.
  - **Instagram Story**: needs a free Facebook App ID (Meta for
    Developers). Can ship with sharing v1.
  - **Snapchat** (Creative Kit: card as sticker + link) and **TikTok**
    (Share Kit: opens TikTok's editor with the card): each needs a
    developer account, an app registration and a **review by the
    platform**. TikTok asks for a public website with terms and a privacy
    policy, so these come after the domain and the legal texts (R2).
  - The Flutter packages for Snapchat and TikTok are not maintained, so
    we write the small native part ourselves.
  - Until the reviews pass, the share sheet already reaches both apps.
- **Links:** Instagram, Snapchat and TikTok do not let an app pre-fill a
  caption or link, so every card that should bring people in carries a
  **short link and a QR code printed on the image**. For WhatsApp the
  link goes in the message, and the link page shows a preview image
  (title, pitch, time).
- **Invite links** are normal web links on our domain that open the app
  if installed, else the Play Store; after install the app opens the
  right game (Play install referrer). Each link carries the inviter's
  code for the invite reward.

### 6.3 Rules

- A card shows only the sharer's own data in full. Other players appear
  as first name + initial; players who chose "nobody sees my games"
  appear as "Player".
- No real club crests, no FIFA-style card design (trademark risk): our
  own card style and a crest generator.
- Players aged 15–17: **initials only** on other people's cards (safe
  default until the legal check of law 18-07; can be relaxed later).
- Nothing is posted automatically; the user always taps Share.

---

## 7. What I think of your ideas

| Your idea | Opinion |
|---|---|
| Tag a friend, he accepts, we search together | Right. Keep it to one tap with a 15-minute limit and "start without him". Always putting friends on the same side is a promise other apps do not make (CeleBreak says friends may be split); it is a selling point. |
| "I have a team" | The call-up with only In / Out and automatic reminders removes the biggest WhatsApp pain. Build it before anything fancy. |
| A team without an opponent → the app builds one from players who want to play | **Your most original idea**: not found in any app for a single match. Three risks: (1) it needs many players in the same area at the same time, so start in Alger and on evenings; (2) strangers drop out more, so standby player, reliability ≥ 80 %, T−10 h check; (3) cash: a solo player in a Selection pays his own share (your rule). With the fallback list (T3) the team always gets an answer. |
| "I want to play against a team but have no team" | Same machine seen from the other side (S4). It also feeds team creation: Selection players who play together are invited to form a team. |
| Every scenario managed | § 3 covers more than 40 situations; the rule that makes it manageable is that all of them reuse the same 7 blocks. |
| Challenges | Yes, but split Friendly / Ranked, otherwise competition brings the toxic behaviour users complain about elsewhere. |
| Sharing to Snap, TikTok, Instagram… | Yes. The simple way (image + share sheet + QR on the card) reaches every network from day one. Direct SDKs can wait. |

**My own suggestions, in the order I would build them:** (1) call-up
In/Out · (2) loan players with clear terms, keepers first · (3) the
Transfer market · (4) suggested share shown in every game · (5) Selection v1 (side B open) ·
(6) result confirmed by both captains + Friendly/Ranked · (7) invite
and result cards · (8) Draft mode · (9) Title holder and Pillar of
the pitch · (10) free pass · (11) win probability · (12) weekly
missions · (13) my month / my year.

---

## 8. Build steps

Fits into the BLUEPRINT order (S23–S40). Screens to design first in
Claude Design are marked ✎.

**R1**

- G1 Group: tag friends, accept, same side (✎ tag sheet v2, invite card).
- G2 Team call-up In/Out, substitutes, co-captain (✎ call-up screen).
- G3 Loan players + the Transfer market (✎ Transfer market, loan post
  sheet).
- G4 Suggested share per player in every game type; organiser's note
  on who plays free; solo players in app-organised games pay their own
  share.
- G5 Direct challenge between teams, Friendly/Ranked, result confirmed
  by both captains, team rating (✎ challenge sheet, result sheet).
- G6 Selection v1: a team game with side B open to anyone.
- G7 Sharing v1: invite card, match poster, result card; share sheet +
  Instagram Story button; invite links. Start the Snapchat and TikTok
  developer registrations (reviews take time).

**R2**

- G8 Find opponent (team matching) + Selection v2 (automatic, standby,
  fallbacks) + "Face a team".
- G9 Draft mode, win probability, level questions, level check.
- G10 Title holder, Pillar of the pitch, awards vote, weekly
  missions, duels, free pass.
- G11 Sharing v2: player card, my month, stickers, team card; direct
  Snapchat and TikTok buttons once their reviews pass.
- G12 House games (venue-hosted).

**R3**

- G13 Evening cups with solo registration, monthly tables, commune derby,
  my year video.

Server side (all in SQL, same rules as the rest): `groups`,
`group_members`; `team_callups`, `callup_answers`; `loan_posts`;
`challenges` (direct or open, slots, kind); `game_sides` (team or Selection
per side, paid flags); `team_ratings`, `team_results`; `titles`;
`missions`; `share_links`. A Selection is a row in `teams` with
`kind = 'select'` that ends with its game.

---

## 9. Decisions

Answered (November 2026):

| # | Question | Answer |
|---|---|---|
| 1 | Who pays what | ✅ Agreed offline between players; the app only suggests the share. Usually each pays his part |
| 2 | Keepers free | ✅ Agreed offline too. Fixed rule: a solo player in a game organised by the app pays his own share |
| 3 | Names | ✅ Known football terms (§ 10); names of teams and Selections chosen by users or given by the app |
| 4 | Free pass every 10 clean games | ✅ Yes |
| 5 | Late arrival | Not decided → default 15 min grace / no-show after 30 min, adjustable |
| 6 | Direct sharing | ✅ Yes for Instagram, **and Snapchat and TikTok** |
| 7 | 15–17 year-olds on cards | Not decided → initials only by default |
| 8 | Ranked for verified players only | ✅ Yes |

---

## 10. Words used in the app (football terms)

Standard French and Arabic, as everywhere in the app. To confirm or
change:

| Thing | English | Français | العربية |
|---|---|---|---|
| Captain's question to his team | Call-up | Convocation | استدعاء |
| Fill-in player for one game | Loan player | Joueur prêté | لاعب معار |
| Player without a team | Free agent | Joueur libre | لاعب حر |
| The Board | Transfer market | Mercato | سوق الانتقالات |
| Team built by the app | Selection | Sélection | منتخب |
| Extra player waiting | Substitute | Remplaçant | احتياطي |
| Game that counts | Official match | Match officiel | مباراة رسمية |
| Game that does not count | Friendly | Match amical | مباراة ودية |
| Rematch | Return leg | Match retour | مباراة الإياب |
| Team rating groups | Division 3 / 2 / 1 / Elite | Division 3 / 2 / 1 / Élite | الدرجة 3 / 2 / 1 / النخبة |
| Venue title | Title holder | Tenant du titre | حامل اللقب |
| Most present player on a pitch | Pillar of the pitch | Pilier du terrain | ركيزة الملعب |
| Cancellation | Yellow card | Carton jaune | بطاقة صفراء |
| No-show | Red card | Carton rouge | بطاقة حمراء |
| Ban | Suspension | Suspension | إيقاف |
| Free pass | Advantage | Avantage | أفضلية |
| Best player of the game | Man of the match | Homme du match | رجل المباراة |
| Friends pick sides in turn | Draft | Tirage des équipes | اختيار الفريقين |

**Names of teams and Selections.** A team's name is chosen by its
captain (checked against a list of forbidden words; no real club names).
A Selection's captain can name it; if he does not, the app gives one
from a list built from the place and a football word ("Sélection Kouba",
"Atlas Bab Ezzouar", "Étoile Hydra"). Bib colours are given by the app.
