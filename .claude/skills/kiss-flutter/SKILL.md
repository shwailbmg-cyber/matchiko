---
name: kiss-flutter
description: "Skill: KISS Flutter Development. Write Flutter code that is simple, small, readable, maintainable, and fast. Use for any Dart/Flutter code in this repo: new screens, providers, repositories, models, tests, refactors and reviews."
---

# Skill: KISS Flutter Development

## Objective

Write Flutter code that is simple, small, readable, maintainable, and fast.
Prefer the simplest solution that works.

## Stack (fixed, don't add alternatives)

| Purpose | Use |
|---|---|
| State management | Riverpod (`flutter_riverpod`, plain `Notifier`/`AsyncNotifier`, no codegen) |
| Navigation | `go_router` |
| Backend calls | `supabase_flutter` (RLS + RPC). Dio only when we call a non-Supabase HTTP API. |
| Models and JSON | `freezed` + `json_serializable` |
| Local key-value | `shared_preferences` (non-sensitive only) |
| Secure tokens | `flutter_secure_storage` |
| Tests | `flutter_test` (unit + widget). No mocking package: hand-written fakes. |

## Structure: feature-first, light clean architecture

```
lib/
  core/            infra with no business types: env, router, theme,
                   generic widgets, format, settings (language)
  shared/          what several features use: domain/ (freezed models,
                   repository interfaces), data/, widgets/, providers.dart
  features/<name>/
    domain/        models + repository interface only this feature uses
    data/          repository implementations (demo, supabase)
    presentation/  *_screen.dart + providers.dart / *_controller.dart
  l10n/            ARB files (en, fr, ar)
```

- Three layers, no more, and only the ones a feature needs. No use-case
  classes unless one has real logic shared by two screens. No mappers when
  the model can `fromJson` the row.
- Features never import each other. Something two features need moves to
  `shared/`. The router (`core/router`) is the only place that knows every
  screen.
- Repositories are providers overridden in `main()` (and in tests); swap
  demo/Supabase in one place. Data providers call `watchGames(ref)` so they
  refetch when the repository's change stream ticks.
- Screen-local UI state (a selected tab, form text) can stay in a
  `ConsumerStatefulWidget`; state shared with a sheet or across screens goes
  in a `Notifier`.

## Rules

1. **Smallest thing that works.** No abstraction until the second use.
2. **Short files and widgets.** Split a widget when its `build` passes
   ~80 lines or a piece repeats. Private widgets (`_Thing`) in the same
   file are fine.
3. **`const` everywhere it compiles.** Stateless by default; `ConsumerWidget`
   to read providers; `StatefulWidget` only for controllers/animations.
4. **State lives in providers, not widgets.** `ref.watch` in `build`,
   `ref.read` in callbacks. `AsyncValue.when` for loading/error/data.
5. **Immutable models** (freezed). `copyWith`, no setters.
6. **No business rules in Dart.** Prices, roles, statuses, XP: the database
   decides; the app displays.
7. **Design tokens only** (`core/theme`), directional layout
   (`EdgeInsetsDirectional`), all text in ARB files (en/fr/ar).
8. **Fast by default**: `ListView.builder` for long lists, no work in
   `build`, `select` to watch only what a widget needs.
9. **Errors**: catch at the repository edge, show a short message and a
   retry; never swallow silently.
10. **Packages**: justify each new one (publisher, maintenance, advisories).

## Done means

- `dart format`, `flutter analyze` clean, `flutter test` green.
- New logic has a unit test; new screen is in the smoke test (opens in
  en/fr/ar at phone size without overflow).
- Reads top to bottom without comments explaining *what*; comments only say
  *why*.

## Smells to remove on sight

God widgets, `setState` holding server data, `dynamic`, `!` on nullable
server data, copy-pasted cards, magic numbers instead of tokens, try/catch
that hides errors, providers that only forward another provider.
