---
name: matchiko-architecture
description: Clean Architecture rules for the Matchiko Flutter app - the dependency rule, the three layers and what goes in each, file and function size limits, naming, data flow, tests per layer, and how to split code that is too long. Use when adding or moving any Dart file in app/lib, creating a feature, screen, controller, provider, repository, model or use case, when a file or function gets long, when arch_lint or rule A8 fails, and when reviewing code structure.
---

# Matchiko architecture

Clean Architecture (Robert C. Martin), in the light form the Flutter team
and the best-known Flutter teachers use: **feature-first, three layers,
every dependency pointing inward**. Rules marked `A1`…`A8` are checked by
the gate (`factory/lints/arch_lint.py`, `diff_lint.py`); the others are
checked by the code reviewer.

`kiss-flutter` says how to write the code inside a file. This skill says
where the file goes, what it may know, and how big it may get.

## 1. The dependency rule

```
 presentation ───────►  domain  ◄─────── data
 widgets, controllers   models, rules,   Supabase, demo data,
 providers              repository       storage, plugins
                        interfaces
```

> Source code dependencies point only inward. Nothing in an inner circle
> knows anything about an outer circle. (R. C. Martin)

`domain` is the centre. It does not know Flutter, Riverpod, Supabase,
Firebase, files or the network. `presentation` and `data` both know
`domain` and **never know each other**. `main.dart` is the only place that
joins them (it picks the demo or the Supabase implementation).

| Uncle Bob's circle | In Matchiko |
|---|---|
| Entities (business objects and rules) | `domain/` models and pure functions (`Game`, `Pitch`, `costShare`) |
| Use cases (application rules) | controllers in `presentation/`; a `domain/usecases/` class only when § 5 says so |
| Interface adapters | `presentation/` (state for widgets) and `data/` (rows ⇄ models) |
| Frameworks and drivers | Flutter, Supabase, Firebase, plugins; wired in `main.dart` and `core/` |

One Matchiko difference: **the app is untrusted**. The rules that matter
(prices, statuses, roles, XP, coins) are enforced in Postgres. The Dart
`domain` mirrors them to display and to validate input early; it is never
the last word.

## 2. Folders

```
app/lib/
  main.dart, app.dart     composition root: builds the repositories, starts the app
  core/                   infrastructure with no business type: env, router,
                          theme, generic widgets, format, settings, push
  shared/                 what two or more features use
    domain/               models, repository interfaces, pure rules
    data/                 repository implementations (demo, Supabase)
    widgets/              widgets that show shared models
    providers.dart        repository providers and app-wide data providers
  features/<name>/
    domain/               models, interfaces, use cases only this feature uses
    data/                 implementations only this feature uses
    presentation/
      <name>_screen.dart        the screen (a view)
      <name>_controller.dart    its state and commands (a view model)
      providers.dart            read-only data providers
      widgets/                  parts of the screen, one widget per file
```

A feature has only the folders it needs. Most features are `presentation/`
only, using `shared/domain`.

## 3. What each layer may hold

### domain: pure Dart

- **A1** Imports only `dart:` libraries (not `dart:ui`, `dart:io`),
  `freezed_annotation`, `json_annotation`, `meta`, `collection`, and other
  `domain/` files. No Flutter, no Riverpod, no backend package.
- Holds: immutable models (freezed), enums, value types, pure functions,
  **abstract** repository classes, use cases.
- A model may carry `fromJson`/`toJson` (generated). The day a table and
  its model stop having the same shape, add a row class in `data/` and map
  there; do not bend the model.
- No `DateTime.now()`, no random, no global state: pass them in, so every
  rule can be tested with fixed values.

### data: the outside world

- **A3** Never imports `presentation/`, widget libraries or `go_router`.
- Holds: repository implementations (`…_supabase.dart`, `…_demo.dart`),
  row ⇄ model mapping, storage and plugin wrappers.
- Each implementation `implements` the interface from `domain/`. Callers
  only ever see the interface.
- Errors are caught here and rethrown as the app's own error types
  (`core/errors.dart`). No Supabase or platform exception leaves `data/`.
- One repository per kind of data (games, pitches, bookings, profile…),
  not one for the whole app. Repositories do not call each other; combine
  them in a controller or a use case.

### presentation: views and view models

- **A2** Never imports a `data/` folder or a backend package
  (`supabase_flutter`, `firebase_*`, `shared_preferences`,
  `flutter_secure_storage`, `dio`, `http`…).
- **A8** A widget file never calls a repository
  (`ref.read(…RepositoryProvider)`). It watches a provider to read, and
  calls a controller method to act.
- A **view** (`*_screen.dart`, `widgets/*.dart`) holds layout only. The
  logic allowed in a widget: show or hide on a flag, animation, layout by
  screen size, simple navigation. Nothing else.
- A **controller** (`*_controller.dart`, a Riverpod `Notifier` or
  `AsyncNotifier`) holds the screen's state as one immutable class and its
  commands as methods (`join()`, `setDay()`). It talks to repositories
  through their interfaces. One controller per screen; no controller for a
  screen that only shows data (a provider in `providers.dart` is enough).
- A controller never imports `material.dart` and never takes a
  `BuildContext`: it returns state, the widget decides what to show.
  Messages for the user are keys or error types, turned into text by the
  widget with `AppLocalizations`.

### core and shared

- **A4** `core/` and `shared/` never import a feature. `core/router` is
  the one exception: it knows every screen. `core/` never imports
  `shared/data`.
- **A5** A feature never imports another feature. What two features need
  moves to `shared/`.

## 4. Size limits

| What | Aim for | Limit | Checked by |
|---|---|---|---|
| Lines in a file (tests too) | 200 | **400** | A6 |
| Lines in a function or method | 20 | **60** | A7 |
| Lines in a widget's `build` | 40 | **80** | A7 |
| Parameters of a function | 3 | 4 positional; more must be named | reviewer |
| Nested `if`/`for`/`switch` levels | 2 | 4 | reviewer |
| Public classes in a file | 1 | 1, plus small private helpers | reviewer |
| Jobs of a class or function | 1 | 1 | reviewer |

The limit is a wall, the aim is the habit: most files should be near the
aim. Generated files (`*.g.dart`, `*.freezed.dart`, `l10n/gen`) do not
count. Code written before these rules is listed in
`factory/lints/arch_baseline.json`; a listed file or function may shrink,
never grow. There is no ignore comment for A1–A7: fix the structure.

### When something is too long

- **A screen file**: move each private widget (`_Header`, `_BookSheet`)
  to `presentation/widgets/<name>.dart` as a public widget, one per file.
  Move every decision and every repository call to the controller.
- **A `build` method**: cut it into widgets, not into `_buildX()` helper
  methods (a widget can be `const`, rebuilds alone and can be tested).
- **A function**: extract the steps into private functions named for what
  they do. If you need a comment to say what a block does, that block is
  a function.
- **A repository**: split by kind of data, one interface and its
  implementations per kind. Shared plumbing (the Supabase client, error
  mapping) goes in one small helper in `data/`.
- **A controller**: if it serves two screens, it is two controllers. Logic
  both need becomes a use case (§ 5).

## 5. Use cases: only when needed

A use case is a class in `domain/usecases/` with one public method,
`call()`, named verb + noun (`SplitGameCost`, `PickBestSlot`). It takes
repositories (interfaces) in its constructor and is pure otherwise.

Create one when **one** of these is true:

1. the same logic is needed by two controllers;
2. the logic needs two repositories;
3. a controller method passes 60 lines because of business logic.

Otherwise the controller calls the repository directly. A use case that
only forwards one repository call is noise: delete it.

## 6. Data flow: one direction

```
tap ─► widget ─► controller.method() ─► repository ─► Supabase
                                                        │
widget ◄─ ref.watch(provider) ◄─ provider ◄─ repository.changes
```

State goes down, events go up. A widget never keeps server data in
`setState`. A provider never writes.

## 7. Names

| File | Class | Layer |
|---|---|---|
| `game.dart` | `Game` (freezed) | domain |
| `game_repository.dart` | `abstract class GameRepository` | domain |
| `split_game_cost.dart` | `SplitGameCost` with `call()` | domain/usecases |
| `game_repository_supabase.dart` | `SupabaseGameRepository implements GameRepository` | data |
| `game_repository_demo.dart` | `DemoGameRepository implements GameRepository` | data |
| `game_screen.dart` | `GameScreen` | presentation |
| `game_controller.dart` | `GameController extends Notifier<GameState>` | presentation |
| `providers.dart` | `gameProvider`, `myGamesProvider` | presentation |
| `widgets/score_card.dart` | `ScoreCard` | presentation |

File names are `snake_case`, one main type per file, the file named after
it. Imports are always `package:matchiko/…` (the analyzer enforces it).

## 8. Tests per layer

| Layer | Test | Needs |
|---|---|---|
| domain | unit test for every rule and use case | nothing (pure Dart) |
| data | the demo repository's behaviour; row ⇄ model mapping with sample rows | no network |
| controller | unit test with a `ProviderContainer` and a hand-written fake repository | no widgets |
| view | widget test: the states (loading, empty, error, data), en and ar | provider overrides |

Hand-written fakes that implement the interface, no mocking package. If a
class is hard to test, it knows too much: move the knowledge inward.

## 9. Before you say "done"

1. Each new file is in the right folder and layer (§ 2, § 3).
2. `python3 factory/lints/arch_lint.py` prints `0 problem(s)`.
3. No file you touched got longer than 400 lines; no function longer than
   60 (80 for `build`).
4. New logic sits in a controller, a use case or the domain, with a unit
   test; widgets only display.
5. `dart format`, `flutter analyze`, `flutter test` are green.

## 10. Where the rules come from

- **Robert C. Martin (Uncle Bob)**: *The Clean Architecture* (2012 article,
  2017 book) for the dependency rule and the circles; *Clean Code* for
  small functions that do one thing and for files of about 200 lines with
  500 as the upper end; SOLID (one job per class, depend on interfaces).
- **Flutter team**, app architecture guide and recommendations
  (docs.flutter.dev/app-architecture): UI layer and data layer, views and
  view models, repository pattern with abstract classes, no logic in
  widgets, one-way data flow, immutable models, dependency injection,
  fakes for tests. A domain layer with use cases is "conditional" there,
  which is why § 5 is strict.
- **Andrea Bizzotto** (Code With Andrea), Riverpod app architecture:
  feature-first folders with the layers inside each feature; presentation,
  application (optional), domain, data.
- **Matt Rešetár (Reso Coder)**, Flutter TDD Clean Architecture: per
  feature `presentation / domain / data`, repository contract in domain and
  implementation in data, use cases with a single `call()`.
- **Very Good Ventures**, layered architecture: a layer talks only to the
  layer next to it, repositories do not depend on each other.
- **DCM (Dart Code Metrics)** default thresholds: about 60 source lines per
  function, 4 to 6 parameters, 5 nesting levels. Ours are at or below them.

Ideas only; no text or code was copied from these sources.
