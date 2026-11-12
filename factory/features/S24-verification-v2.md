---
id: S24
title: Verification v2 (one ID = one account, age 15+, trust levels)
release: R1
order: 40
kind: build
status: ready
risk: high
surfaces: [security]
depends_on: [Q2]
sources: [docs/BLUEPRINT.md#3.1, docs/BLUEPRINT.md#7.1, docs/FEATURES.md (A4 A5 F2)]
---

# S24 Verification v2 (one ID = one account, age 15+, trust levels)

## Goal

A banned or duplicate person cannot start again with a new email, players
under 15 are not verified, and what a player may do depends on his trust
level. All enforced in the database.

## Rules

1. At verification the manager types the **ID card number** and the
   **year of birth**. The server stores only
   `HMAC-SHA256(normalised number, server secret)` in a unique column.
   The number itself is never stored or logged.
2. The secret lives in Supabase Vault (`id_hash_secret`), created by the
   migration when missing, readable only inside the database. For the
   local tests (no Vault) a database setting supplies it.
3. The same ID on a second account → error `id_already_used`; nothing
   changes.
4. Age under 15 (current year − birth year < 15) → error `under_age`.
5. **Trust levels**, computed by one SQL function from existing data:
   - `new`: not verified.
   - `verified`: verified.
   - `reliable`: verified, ≥ 5 completed games, reliability ≥ 90 %.
   - `restricted`: ≥ 5 completed games and reliability < 70 %.
   - `banned`: `booking_ban_until` in the future.
6. Limits, checked inside the existing functions:
   - `new` and `restricted`: at most 2 upcoming games; cannot book;
     `restricted` cannot open a game to others.
   - `verified`: 1 pending booking request, 4 upcoming games.
   - `reliable`: 3 pending booking requests.
   - `banned`: nothing new.
7. Bans: 2 no-shows in 60 days → 7 days; a 3rd in 60 days → 30 days
   (BLUEPRINT § 8, decided).

## Steps

- [ ] 1. **db** Migration: `profiles.id_hash` (unique, no grants), `profiles.birth_year`; the secret (rule 2); replace `verify_player` by `verify_player(p_handle, p_id_number, p_birth_year)` with rules 1, 3, 4 (drop the old signature; keep every existing check: managers only, not yourself, the queue). pgTAP: allow, duplicate ID, under age, a player cannot call it, the hash column is unreadable by players.
- [ ] 2. **db** Migration: `trust_level(p_user)` and `my_trust()` (JSON: level, limits, what is needed for the next level); limits of rule 6 in `request_booking`, `join_open_game` and `set_game_open` (`create or replace`, same signatures); ban rule 7 in `apply_no_show`. pgTAP for each level and each limit, including the deny cases.
- [ ] 3. **app** `verifyPlayer(handle, idNumber, birthYear)` and `myTrust()` in the repository interface, demo and Supabase repositories; `TrustLevel` model; typed errors for `id_already_used` and `under_age`; unit tests.
- [ ] 4. **ui** Manager verification sheet: ID number and year-of-birth fields with validation, the two error messages; profile: "Trust level" card (level, limits, next level). Texts in en/fr/ar. Widget tests. The ID number field is never logged, never kept in state after the call.

## Acceptance criteria

- AC1 (step 1, pgTAP): verifying with a valid ID and age sets `verified_at` and a hash; the stored value is not the number.
- AC2 (step 1, pgTAP): the same ID on another account raises `id_already_used`; year of birth making the player 14 raises `under_age`.
- AC3 (step 1, pgTAP): `select id_hash from profiles` is refused for `authenticated`; a non-manager calling `verify_player` is refused.
- AC4 (step 2, pgTAP): each of the five levels is returned for a matching fixture.
- AC5 (step 2, pgTAP): a `new` player's third upcoming join is refused; a `verified` player's second pending booking is refused; a `reliable` player's third is accepted.
- AC6 (step 2, pgTAP): the 3rd no-show within 60 days sets a 30-day ban.
- AC7 (step 4, widget test): the manager sees both error messages; the trust card shows the level from `myTrust()`.

## Out of scope

Appeals (S27). Rate limits per day (S25). Admin tools to reset an ID (S30).
