---
name: matchiko-security
description: Security review checklist for Matchiko (Flutter app + Supabase backend). Use before merging any change that touches auth, roles, RLS policies, SQL functions, bookings, payments (SATIM/cash QR), coins/XP, verification (ID photos), storage buckets, Edge Functions, deep links, or release builds. Also use when asked for a "security check" or "audit" of this repo.
---

# Matchiko security review

Matchiko runs on trust in a cash market: bookings, verification, QR scans,
coins and XP are all things people will try to fake. Assume the Flutter app
is fully controlled by an attacker. **Every rule lives in Postgres (RLS +
SQL functions) or in Edge Functions, never only in Dart.**

## Workflow

1. List what the change touches (tables, functions, buckets, screens, packages).
2. Walk the matching sections below and note each item as OK / FIX / N/A.
3. For SQL changes, run the pgTAP tests in `supabase/tests/`, or add one for
   any new policy or function (one allow case, one deny case minimum).
4. For dependency changes, use the `supply-chain-risk-auditor` skill.
5. For a whole-branch review, use `differential-review` on the diff.
6. Report findings ranked by impact, with file:line and a concrete fix.

## Threat model (what attackers want)

| Goal | Attack | Defense we rely on |
|---|---|---|
| Free coins / XP | Insert or update own `wallet_ledger` / `profiles.xp` | No client INSERT/UPDATE grants; only `security definer` functions write the ledger |
| Fake Guaranteed status | Call update on `bookings.status` | Status changes only through `confirm_booking`, `scan_booking_qr`, the SATIM webhook |
| Become a manager / referee | Edit role in profile or JWT `user_metadata` | Roles in `venue_managers` / `referees` tables, written by admins/managers only |
| Self-verify | Set `profiles.verified = true` | Column not updatable by `authenticated`; only `verify_player` (manager of a venue) |
| Forge a booking QR | Guess or reuse a code | QR = random 128-bit token stored server-side, single use, checked against the scanning manager's venue |
| Spoof SATIM payment | Call the callback URL directly | Webhook re-queries SATIM `getOrderStatus` server-side with secret creds before marking paid |
| Stalk players | Read other players' phone or exact location | `profiles.phone` has no SELECT grant; only the owner and managers of a venue they booked can read it. No ID photos are stored (verification is in person). |
| Spam bookings / no-shows | Many requests from one account | Unverified users can't book; rate limits in functions; booking ban after 2 no-shows |

## Supabase / Postgres checklist

- [ ] RLS enabled on **every** table in `public` (and any exposed schema). New table without RLS = blocker.
- [ ] Policies match the real access model (not a copy-pasted `auth.uid() = user_id` everywhere). Separate `select` / `insert` / `update` / `delete` policies; `update` has both `using` and `with check`.
- [ ] Wrap `auth.uid()` as `(select auth.uid())` in policies (performance, see `supabase-postgres-best-practices`).
- [ ] No authorization based on `auth.jwt() -> 'user_metadata'` (user-editable). Roles come from tables or `app_metadata`.
- [ ] Sensitive columns (`verified`, `xp`, `coins`, `role`, `booking_ban_until`, `status`, `qr_token`) are protected by column-level grants or a trigger; the client can't write them.
- [ ] Every `security definer` function: `set search_path = ''`, fully-qualified names, checks the caller (`auth.uid()`) and their right to act (e.g. is manager of *this* venue), validates every argument, and is `revoke`d from `public`/`anon` and granted only to `authenticated` (or `service_role`).
- [ ] State machines enforced in SQL: `requested → confirmed → guaranteed → completed`, plus `cancelled` / `no_show`. Illegal transitions raise.
- [ ] No double booking: exclusion constraint on `(pitch_id, tstzrange)` for active bookings.
- [ ] Views use `security_invoker = true` (otherwise they bypass RLS).
- [ ] `service_role` / secret keys only in Edge Functions env and CI secrets. **Never** in the Flutter app, `.env` committed files, or `--dart-define` of release builds.
- [ ] Storage: avatars only (public-read OK, upload only to `auth.uid()/…`). No ID documents are ever uploaded.
- [ ] Realtime: only tables whose RLS is correct are in the publication; private channels for offers.
- [ ] Run the Supabase security advisor (`supabase db lint` / dashboard Advisors) and fix any ERROR.

## Edge Functions checklist (SATIM, notifications, matchmaking)

- [ ] Verify the caller's JWT (default `verify_jwt = true`); webhooks that can't send a JWT verify a signature or re-query the provider instead.
- [ ] Amounts computed server-side from the booking row, never taken from the request body.
- [ ] Idempotency: the same SATIM order or webhook processed twice changes nothing the second time.
- [ ] Secrets read from `Deno.env`, never logged. Error responses don't leak stack traces or SQL.
- [ ] CORS limited to what's needed.

## Flutter app checklist (OWASP MASVS)

- [ ] **Storage**: session tokens in `flutter_secure_storage` (supabase_flutter's default local storage is OK for the session; nothing else sensitive in `shared_preferences`). No PII in logs (`debugPrint` stripped from release).
- [ ] **Crypto/keys**: only the Supabase URL and publishable (anon) key ship in the app. Nothing that grants more than RLS allows.
- [ ] **Auth**: Google (`signInWithIdToken`) or email code via Supabase Auth; handle `AuthException`; sign out clears Google + Supabase sessions; no "role" chosen on the client that the server trusts. Phone numbers stay private (`get_my_profile`, `booking_contact` only).
- [ ] **Network**: HTTPS only (`android:usesCleartextTraffic="false"`, no ATS exceptions).
- [ ] **Platform**: deep links (`matchiko://`, app links) validate parameters and never perform an action without user confirmation; `android:exported` set deliberately; no WebView JS bridges.
- [ ] **Code**: release builds use `--obfuscate --split-debug-info`; no debug banners/feature flags that unlock admin paths.
- [ ] **Privacy**: location permission "while in use" only; exact coordinates of other players never shown; camera only on the manager's QR scan and ID upload screens.
- [ ] **Resilience**: app works if the user tampers with local state; the server rejects anything invalid.

## CI / supply chain

- [ ] New packages: check publisher (verified on pub.dev), popularity, last release, and open advisories (`dart pub outdated`, OSV).
- [ ] GitHub Actions: pinned action SHAs, minimal `permissions:`, no secrets in PR workflows from forks (see `agentic-actions-auditor`).
