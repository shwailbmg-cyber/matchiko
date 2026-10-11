# Build loop

How Claude builds Matchiko on its own: one step at a time, and every step
is tested and pushed before the next one starts. To continue in any session,
say **"run the build loop"** (skill `build-loop`). Claude picks the first
unchecked step in the backlog below and keeps going.

## The loop (for every step)

```
1. PICK      First unchecked step in the backlog. Mark it in progress.
2. READ      Only the files the step needs: PRODUCT.md section, the
             prototype screen (design/prototype), existing feature code.
3. BUILD     Follow kiss-flutter (structure, Riverpod, freezed, tokens,
             l10n en/fr/ar, directional layout). SQL only as new migrations.
4. TEST      dart format · flutter analyze (0 issues) · flutter test
             (+ new unit/widget tests, screen added to the smoke test)
             · supabase/tests/local/run.sh when SQL changed.
5. SECURE    owasp-mobile-flutter on the Dart diff; matchiko-security +
             owasp-security when auth, RLS, RPCs, storage or CI changed.
             Fix findings before pushing.
6. PUSH      Commit (one step = one commit or a few), push the branch.
             CI must go green: analyze, tests, DB tests, web, APK.
7. RECORD    Tick the step here, note anything deferred, update ROADMAP
             if a milestone moved.
8. NEXT      Go to 1. Stop only when the backlog is empty or a step needs
             a decision only the user can make (then ask, and skip ahead to
             the next independent step meanwhile).
```

Rules that keep the loop cheap and safe:

- One step at a time; never leave the tree red between steps.
- If a test fails twice for the same reason, step back and simplify.
- Don't edit an applied migration; don't add a package without a reason.
- Never push to `main` directly; work on the feature branch, the user merges.

## Definition of done (every step)

- Works in demo mode (no backend) and doesn't break Supabase mode.
- All text in `app_en/fr/ar.arb`; Arabic RTL looks right.
- `flutter analyze` 0 issues, all tests green, CI green on the pushed commit.
- No new security finding left open.

## Backlog

Status: `[x]` done · `[ ]` to do. Milestones refer to `docs/ROADMAP.md`.

- [x] **S1** Skills: OWASP (`owasp-security`, `owasp-mobile-flutter`),
      `kiss-flutter`, this loop (`build-loop`).
- [x] **S2** Brand color: blue–magenta violet; pitch turf stays green.
- [x] **S3** Architecture: feature-first + light clean architecture,
      Riverpod instead of provider, freezed + json_serializable models.
- [x] **S4** Security basics: session in `flutter_secure_storage`, release
      hardening (obfuscate, `allowBackup=false`, cleartext off).
- [x] **S5** Splash + onboarding (name, city, positions, level, phone) +
      edit profile. (M1)
- [x] **S6** Pitch list with search and filters (format, price, lights,
      covered, showers) + favourites. (M2)
- [x] **S7** Wallet: coins, XP, rank progress, history. (M5)
- [x] **S8** Public profile + friends (search by @handle, add, invite). (M3)
- [x] **S9** Notifications center + report no-show / report player. (M3)
- [x] **S10** Teams: list, create, team page, recurring game. (M4)
- [x] **S11** Referee: apply, availability, jobs, earnings, match report. (M5)
- [ ] **S12** Manager calendar: week view, block slot, walk-in booking. (M3)
- [ ] **S13** Manager venue: pitches and prices, opening hours. (M3)
- [ ] **S14** Manager scan modes (booking, verification, check-in) +
      players tab (referee applications, no-show reports). (M3)
- [ ] **S15** Manager reports (cash expected vs received, occupancy) +
      staff. (M6)
- [ ] **S16** Settings complete: notifications, privacy, blocked users,
      help, terms/privacy, delete account. (M1)
- [ ] **S17** Empty / error / offline states on every screen.
- [ ] **S18** Supabase repositories: profile, pitches/slots, bookings,
      games (replace demo data when `env/dev.json` is set). (M1–M2)

## Notes and deferred items

- Dio is not added: every backend call goes through `supabase_flutter`.
  Add Dio only when we call a non-Supabase HTTP API.
- Map view (S6) waits for a map package decision (cost and licence).
- Communes (1,541): need an up-to-date dataset after decree n° 26-206
  moved communes into the 11 new wilayas; add a `communes` table then.
  Wilayas (69) are done.
- Public reliability % and fair-play tags need a `public_player_stats`
  RPC that doesn't expose raw no-show counts (with S18).
- Profile photo upload waits for the Supabase avatars bucket (S18).
