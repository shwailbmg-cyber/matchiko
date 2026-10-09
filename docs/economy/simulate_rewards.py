"""Monte Carlo model of Matchiko's XP and coins economy.

Simulates 12 months for three player types and reports how long each takes to
reach each rank, and how many coins they earn. Used to pick the XP values in
`supabase/migrations/*_reward_rules.sql`. Re-run after changing any value:

    python3 docs/economy/simulate_rewards.py
"""

import random
import statistics

RANKS = [("silver", 500), ("gold", 1000), ("elite", 2000), ("legend", 3500)]

# Coins are locked product decisions. XP is what we tune.
COINS = dict(show_up=20, rate_game=10, referee=50, win=30, goal=30, mvp=30,
             verified=200, no_show=-30)

CANDIDATES = {
    "A: flat 20/game": dict(show_up=20, rate_game=5, referee=40, win=30, goal=10,
                            mvp=30, verified=0, first_game=0, no_show=-50),
    "B: 30/game + onboarding": dict(show_up=30, rate_game=5, referee=40, win=15,
                                    goal=10, mvp=25, verified=100, first_game=50,
                                    no_show=-50),
    "C: 40/game + onboarding": dict(show_up=40, rate_game=5, referee=40, win=20,
                                    goal=10, mvp=30, verified=100, first_game=50,
                                    no_show=-50),
}

# Player types. games_per_month is the mean of a Poisson draw each month.
PERSONAS = {
    "casual (2 games/mo)": dict(games_per_month=2, no_show=0.06, rates=0.35, referees=0),
    "regular (6 games/mo)": dict(games_per_month=6, no_show=0.03, rates=0.55, referees=0),
    "hardcore (12 games/mo)": dict(games_per_month=12, no_show=0.02, rates=0.75, referees=0),
    "referee (6 games + 4 ref/mo)": dict(games_per_month=6, no_show=0.02, rates=0.6, referees=4),
}

# Per-game odds in a 6v6 (12 players, ~8 goals, ~45% win / ~10% draw).
P_WIN = 0.45
P_SCORES = 0.40          # player scores at least once
P_REFEREED = 0.30        # share of games with a referee (MVP only exists there)
P_MVP_IF_REFEREED = 1 / 12

MONTHS = 12
RUNS = 4000
SEED = 7


def poisson(rng, lam):
    # Knuth; fine for small lambda.
    limit, k, p = pow(2.718281828459045, -lam), 0, 1.0
    while True:
        p *= rng.random()
        if p <= limit:
            return k
        k += 1


def simulate(xp_rule, persona, rng):
    xp = xp_rule["verified"]
    coins = COINS["verified"]
    reached = {}
    played_any = False
    for month in range(1, MONTHS + 1):
        days = [rng.random() for _ in range(poisson(rng, persona["games_per_month"]))]
        for d in sorted(days):
            t = month - 1 + d
            if rng.random() < persona["no_show"]:
                xp = max(0, xp + xp_rule["no_show"])
                coins = max(0, coins + COINS["no_show"])
                continue
            xp += xp_rule["show_up"]
            coins += COINS["show_up"]
            if not played_any:
                xp += xp_rule["first_game"]
                played_any = True
            if rng.random() < P_WIN:
                xp += xp_rule["win"]
                coins += COINS["win"]
            if rng.random() < P_SCORES:
                xp += xp_rule["goal"]
                coins += COINS["goal"]
            if rng.random() < P_REFEREED and rng.random() < P_MVP_IF_REFEREED:
                xp += xp_rule["mvp"]
                coins += COINS["mvp"]
            if rng.random() < persona["rates"]:
                xp += xp_rule["rate_game"]
                coins += COINS["rate_game"]
            for name, need in RANKS:
                if name not in reached and xp >= need:
                    reached[name] = t
        for _ in range(poisson(rng, persona["referees"])):
            xp += xp_rule["referee"]
            coins += COINS["referee"]
            for name, need in RANKS:
                if name not in reached and xp >= need:
                    reached[name] = month - 0.5
    return xp, coins, reached


def fmt_months(values, runs):
    if len(values) < runs * 0.5:
        return f"{100 * len(values) / runs:>3.0f}% in 1y"
    return f"{statistics.median(values):>4.1f} mo"


def main():
    rng = random.Random(SEED)
    for cname, rule in CANDIDATES.items():
        print(f"\n== {cname}")
        print(f"{'persona':30} {'silver':>11} {'gold':>11} {'elite':>11} {'legend':>11} "
              f"{'XP 1y':>7} {'coins 1y':>9}")
        for pname, persona in PERSONAS.items():
            hits = {n: [] for n, _ in RANKS}
            xps, coins = [], []
            for _ in range(RUNS):
                xp, c, reached = simulate(rule, persona, rng)
                xps.append(xp)
                coins.append(c)
                for n, t in reached.items():
                    hits[n].append(t)
            cols = " ".join(f"{fmt_months(hits[n], RUNS):>11}" for n, _ in RANKS)
            print(f"{pname:30} {cols} {statistics.median(xps):>7.0f} "
                  f"{statistics.median(coins):>9.0f}")


if __name__ == "__main__":
    main()
