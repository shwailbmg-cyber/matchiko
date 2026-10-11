---
name: build-loop
description: Runs Matchiko's autonomous build loop - pick the next unchecked step in docs/LOOP.md, build it the KISS way, test, security-check, push, wait for green CI, tick it, repeat. Use when the user says "run the build loop", "continue building", "next step", or asks to keep building the app on its own.
---

# Build loop

1. Read `docs/LOOP.md` (the loop, the definition of done, the backlog).
2. Take the first `[ ]` step. Read only what it needs.
3. Build with `kiss-flutter`. Data in demo repositories first; the database
   rules stay in Postgres.
4. From `app/`: `dart format lib test && flutter analyze && flutter test`.
   From the repo root when SQL changed: `supabase/tests/local/run.sh`.
5. Security: `owasp-mobile-flutter` on Dart changes; `matchiko-security`
   and `owasp-security` when auth, RLS, RPCs, storage, deep links or CI change.
6. Commit with the attribution lines, `git push -u origin <branch>`, then
   watch CI until it finishes (GitHub API:
   `/repos/<owner>/<repo>/actions/runs?branch=<branch>&per_page=1`). Fix red CI before moving on.
7. Tick the step in `docs/LOOP.md` (same commit or a follow-up), then go to
   step 2 with the next one.

Stop and ask only for decisions the user must make (money, legal, a new
paid service). Keep reports short: step done, tests, CI, link.
