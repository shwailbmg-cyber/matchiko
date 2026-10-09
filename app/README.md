# Matchiko app (Flutter)

```bash
flutter pub get
flutter run                                         # demo mode, no backend
cp env/dev.example.json env/dev.json                # then fill in from `supabase status`
flutter run --dart-define-from-file=env/dev.json    # against Supabase
flutter analyze && flutter test
```

Release builds: `flutter build appbundle --obfuscate --split-debug-info=build/symbols --dart-define-from-file=env/prod.json`.

Translations live in `lib/l10n/app_{en,fr,ar}.arb` (generated from the prototype by
`design/tools/i18n_to_arb.js`, app-only keys are kept). Run `flutter gen-l10n` after editing.

Architecture and conventions: see `../CLAUDE.md` and `../docs/ARCHITECTURE.md`.
