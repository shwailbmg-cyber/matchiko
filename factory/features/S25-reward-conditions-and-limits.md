---
id: S25
title: Reward conditions, caps and rate limits
release: R1
order: 50
kind: build
status: ready
risk: high
surfaces: [security]
depends_on: [Q2]
sources: [docs/BLUEPRINT.md#6.2, docs/BLUEPRINT.md#7.3]
---

# S25 Reward conditions, caps and rate limits

## Goal

XP and coins can only be earned in real games, and no account can flood
the system with requests.

## Rules

1. A game pays rewards only if the booking was **Guaranteed**, then
   **completed by the manager**, and at least **6 real players** (not
   guests) were marked present.
2. Caps per player: **2 rewarded games per day, 8 per week**; ratings
   rewarded 2 per day; refereeing 3 per day. Above a cap the game still
   counts for statistics and reliability, without XP or coins.
3. Caps are data (a table), editable without a release.
4. Rate limits, checked inside the functions, per user:
   booking requests 6 / day · join or leave a game 10 / day · match
   searches 30 / hour · friend requests 20 / day · reports 5 / day ·
   support messages 5 / day · verifications by one manager 60 / day.
5. Above a limit the function raises `rate_limited`; nothing is written.
6. Penalties (no-show, cancellation) are never capped.

## Steps

- [ ] 1. **db** Migration: `reward_caps` table (reason group, per-day, per-week; RLS, readable by authenticated, no writes); `award()` applies rule 2; `complete_booking` applies rule 1 before any reward. pgTAP: a 5-player game pays nothing; a not-guaranteed booking cannot be completed (existing rule kept); the 3rd game of a day pays nothing but is counted; penalties still apply.
- [ ] 2. **db** Migration: `rate_limits` table (user, action, window start, count; no client access) and `check_rate(p_action)`; called at the start of `request_booking`, `join_open_game`, `confirm_coming(false)`, `find_match`, friend request insert (trigger), `player_reports` insert, `support_messages` insert, `verify_player`. pgTAP: the limit+1 call raises `rate_limited` and writes nothing; another user is not affected; a new window resets the count.
- [ ] 3. **ui** A clear message for `rate_limited` ("Too many attempts. Try again later.") shown by the existing error snackbar, in en/fr/ar; a unit test for the error mapping. No new screen.

## Acceptance criteria

- AC1 (step 1, pgTAP): completing a guaranteed game with 6 present players pays `show_up` to each; with 5 it pays nothing.
- AC2 (step 1, pgTAP): a player's 3rd completed game in one day adds no ledger reward row but his attended count increases.
- AC3 (step 1, pgTAP): a no-show penalty is written even when the daily cap is reached.
- AC4 (step 2, pgTAP): the 7th booking request in a day raises `rate_limited`; the 6th succeeds.
- AC5 (step 2, pgTAP): `rate_limits` cannot be read or written by `authenticated` (deny case).
- AC6 (step 3, unit test): the error with code `rate_limited` maps to the l10n message in the three languages.

## Out of scope

Invite reward and its cap (S29). Fraud signals (S37). CAPTCHA on sign-in
codes (Supabase Auth setting, see BLUEPRINT § 7.3).
