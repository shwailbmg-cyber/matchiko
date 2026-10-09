# Rewards economy (XP and coins)

Two numbers, as decided: **Rank XP** sets the tier and can't be spent;
**coins** are a wallet for the store. Coin amounts per action are locked by
the product owner. XP amounts and store prices were set with the model below.

## How similar products set these

- **Tier curves** (game design, Duolingo-style leagues): quick early wins,
  slower later tiers, and time-to-tier checked against how often real users
  show up. Linear curves feel too slow early and too fast late; flat curves
  let heavy users race through. ([Game Developer](https://www.gamedeveloper.com/design/quantitative-design---how-to-define-xp-thresholds-), [FeverBee](https://www.feverbee.com/gamificationcurve/))
- **Points as money** (retail loyalty programs): give back about **1–5 % of
  what a customer spends**. The first reward should come within **2–3
  visits**. Keep the coin-to-value rate fixed, and don't launch generous and
  cut later: that destroys trust. Typically 20–50 % of points get redeemed. ([Rivo](https://www.rivo.io/blog/points-program-redemption-rate), [Toki](https://www.buildwithtoki.com/blog-post/points-based-loyalty-program), [8x](https://eightx.co/blog/loyalty-program-economics-5pct-earn-rate))
- **Reliability over skill** (Footy Addicts, Playtomic): no-shows hurt a
  visible reliability score and cost money or access, and a no-show voids the
  game's effect on levels. ([Playtomic](https://playerhelp.playtomic.com/hc/en-gb/articles/43240624037393), [Footy Addicts](https://www.footyaddicts.com/))

## Model

`docs/economy/simulate_rewards.py`: 4,000 simulated players per type over
12 months. Games per month follow a Poisson distribution. In each game: show
up or no-show, win 45 %, score 40 %, referee present 30 % (MVP 1 in 12 then),
and rate the game 35–75 % of the time depending on the player type.

Targets (rank thresholds are locked at 500 / 1000 / 2000 / 3500):
Silver within ~1–2 months for a regular, Gold within a season (~3 months),
Elite as a 6–9 month goal, Legend rare (top players, ~6+ months).

Median months to reach each rank:

| Player type | Option A: 20 XP/game | **Option B: 30 XP/game + onboarding (chosen)** | Option C: 40 XP/game |
|---|---|---|---|
| Casual, 2 games/mo | Silver 7.1 · Gold 23 % in 1 y | **Silver 4.7 · Gold 9.9** | Silver 3.6 · Gold 8.4 |
| Regular, 6 games/mo | 2.2 · 4.4 · 8.7 · Legend 3 % in 1 y | **1.4 · 3.4 · 7.5 · Legend 17 % in 1 y** | 1.1 · 2.7 · 5.8 · 10.2 |
| Hardcore, 12 games/mo | 1.0 · 2.1 · 4.2 · 7.3 | **0.7 · 1.6 · 3.6 · 6.5** | 0.5 · 1.3 · 2.8 · 5.0 |
| Referee, 6 games + 4 refs/mo | 1.4 · 2.5 · 5.0 · 8.7 | **0.6 · 2.1 · 4.5 · 8.1** | 0.6 · 1.7 · 3.7 · 6.8 |

A makes casual players wait 7 months for their first rank-up. C turns Legend
into a 10-month routine for regulars. **B** hits the targets.

## Chosen values

In `supabase/migrations/20261009000400_reference_data_and_rewards.sql`:

| Action | XP | Coins (locked) |
|---|---|---|
| Show up to a game | 30 | 20 |
| First game ever (once) | 50 | 0 |
| Get verified (once) | 100 | 200 |
| Win | 15 | 30 |
| Score (once per game) | 10 | 30 |
| MVP | 25 | 30 |
| Rate the game | 5 | 10 |
| Referee a game | 40 | 50 |
| Pay online | 0 | 15 |
| Invite a friend who plays | 0 | 100 |
| No-show | −50 | −30 |

A no-show (−50 XP) wipes out more than one game's XP (≈ 46 on average), so
skipping never pays.

## Coins: a warning about store prices

A regular player earns about **3,750 coins a year (~310/month)** and spends
about 6 × 210 DA = 1,260 DA a month on games. With the prototype's store
prices (free referee = 400 coins for a 200 DA service), 1 coin ≈ 0.5 DA, so
players get back **~12 % of what they spend**. That's 2–10× more than
loyalty programs give. Recommendation: keep the locked earn amounts and set
store prices at **1 coin ≈ 0.2 DA (~5 % back)**. Items that cost us nothing
(cosmetics, community access) stay cheap, so the first reward still comes
within 2–3 games:

| Store item | Prototype | Suggested | Paid by |
|---|---|---|---|
| Profile frame | 150 | 150 | free to us |
| Community access | 300 | 300 | free to us |
| Free referee (200 DA) | 400 | 1,000 | us / referee pool |
| Pitch discount 10 % (~250 DA) | 500 | 1,250 | partner pitch |
| Tournament ticket (~500 DA) | 800 | 2,500 | organiser |
| Sponsor jersey | 2,500 | 4,000 | sponsor |

The store is "Soon" at launch, so nothing is committed yet. Decide before it opens.
