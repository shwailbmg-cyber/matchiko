# Matchiko

An app for organising small football games (5v5 / 6v6 / 8v8) in Algeria.
Players find or join games and book pitches, stadium managers confirm, scan
and verify, and referees log matches. **Flutter** app + **Supabase** backend.

Read first: `docs/ARCHITECTURE.md` (the main loop, data model, security) and
`docs/ROADMAP.md` (what's built, what's next).
Design reference: `design/prototype/Matchiko.html` + `design/prototype/BRIEF.md`.
Every screen should match the prototype (colors, spacing, copy).

## Commands

```bash
# App (from app/)
flutter pub get
flutter analyze
flutter test
flutter run                                       # demo mode, no backend
flutter run --dart-define-from-file=env/dev.json  # with Supabase
flutter gen-l10n                                  # after editing lib/l10n/*.arb
dart format lib test

# Database (from repo root)
supabase start && supabase db reset && supabase test db   # needs Docker
supabase/tests/local/run.sh                                # plain Postgres + pgTAP, no Docker
```

Cloud sessions get Flutter and pgTAP from `.claude/hooks/session-start.sh`.

## Rules

- **The app is untrusted.** Every rule that matters (prices, statuses, roles,
  XP/coins, verification) lives in Postgres: RLS + `security definer` RPCs
  with `set search_path = ''`. The Dart side only displays it.
- New table → enable RLS, revoke the default grants, grant only what's
  needed, add a pgTAP test with an allow case and a deny case.
- Schema changes are new files in `supabase/migrations/` (never edit an
  applied migration).
- Architecture: `lib/ui/features/<feature>/{views,view_models}`, repositories
  in `lib/data/repositories`, pure models in `lib/domain/models`. View models
  are `ChangeNotifier`s injected with `provider`.
- Directional layout only (`EdgeInsetsDirectional`, `AlignmentDirectional`) so
  Arabic RTL works. Design tokens from `lib/ui/core/theme/`, not raw hex.
- User-facing text goes in `app/lib/l10n/app_{en,fr,ar}.arb`, all three
  languages. Keep the user's wording verbatim.
- KISS: the simplest thing that works and still scales. No new package
  without a reason (check pub.dev publisher, maintenance, advisories).
- Before merging: `flutter analyze`, `flutter test`, the DB tests, and the
  `matchiko-security` skill on the diff.

## Skills in this repo (`.claude/skills/`)

- Flutter/Dart (official): architecture, routing, localization, layouts,
  widget/integration tests, static analysis, mocks, coverage.
- Supabase (official): `supabase`, `supabase-postgres-best-practices`.
- Security: `matchiko-security` (project checklist), plus Trail of Bits'
  `differential-review`, `sharp-edges`, `semgrep`,
  `supply-chain-risk-auditor`, `agentic-actions-auditor`.

Sources and licenses: `.claude/skills/THIRD_PARTY.md`.

## User preferences

Concise answers. Keep the user's text verbatim. KISS and scalable.
