---
id: Q2
title: Clean architecture cleanup (split long files, controllers for screens)
release: R1
order: 15
kind: build
status: ready
risk: medium
surfaces: []
depends_on: [Q1]
sources: [.claude/skills/matchiko-architecture/SKILL.md, factory/lints/arch_baseline.json, docs/FACTORY.md#gate]
---

# Q2 Clean architecture cleanup

## Goal

The code written before the architecture rules follows them too: no file
over 400 lines, no function over 60, widgets that only display, one
repository per kind of data. Later features are then built on a clean
base and the list of known violations is empty.

## Rules

1. Refactor only. What the app does, how it looks and every text stay the
   same. No new feature, no new package, no migration, no new translation
   key.
2. No existing test is deleted, skipped or loosened. Tests may move with
   the code they test. The design tests from Q1 stay green.
3. At the end `python3 factory/lints/arch_lint.py --all` prints no line
   starting with `known`: nothing in the app needs the baseline any more.
4. No widget file (`*_screen.dart`, `*_sheet.dart`, `widgets/`,
   `shared/widgets/`) reads a repository provider. A screen that acts has
   a controller; a screen that only shows data watches a provider.
5. Every controller added has a unit test that uses a hand-written fake
   repository.
6. `GameRepository` is split by kind of data (games and bookings, pitches,
   players and friends, teams, referee, manager, notifications, settings
   and safety): one abstract class in `shared/domain/`, one demo and one
   Supabase implementation in `shared/data/`, one provider each. Demo
   implementations share one in-memory store so the demo app behaves as
   before.
7. The job does not edit `factory/lints/arch_baseline.json` (protected).
   Old entries are harmless once the code is under the limits.
8. The lints `avoid_dynamic_calls` and `avoid_positional_boolean_parameters`
   are switched on in `app/analysis_options.yaml` with no finding.

## Steps

- [ ] 1. **app** Demo data: split `shared/data/game_repository_demo.dart` into the seed data, one in-memory store and one file per kind of data (rule 6 names them), each under 400 lines and every function under 60. `DemoGameRepository` keeps its public behaviour; the demo repository tests pass unchanged.
- [ ] 2. **app** Supabase: split `shared/data/game_repository_supabase.dart` the same way, with the shared plumbing (client, error mapping, row helpers) in one small file. Switch on `avoid_dynamic_calls` and fix its findings with typed rows.
- [ ] 3. **app** Interfaces and providers: split `GameRepository` into one abstract class and one provider per kind of data; `main.dart` wires demo or Supabase for each. Move every caller to the narrow interface it needs. The settings screen no longer imports `shared/data`.
- [ ] 4. **ui** Game, pitch and play screens: private widgets move to `presentation/widgets/` (one widget per file), every repository call and decision moves to the screen's controller, each `build` is under 80 lines.
- [ ] 5. **ui** Home, profile, profile form, player, settings, notifications and friends: the same treatment, plus `shared/widgets/friend_button.dart` and `favorite_button.dart`.
- [ ] 6. **ui** Manager screens (today, calendar, scan, venue, reports, players): the same treatment.
- [ ] 7. **ui** Referee, match report, teams, team and login screens: the same treatment. Then the last long functions (`buildMkTheme`, `MkNavBar._button`) and `avoid_positional_boolean_parameters` switched on with no finding.

## Acceptance criteria

- AC1 (steps 1-3, unit tests): the existing demo repository and model tests pass with no change to what they assert.
- AC2 (step 3, unit test): GIVEN the demo app WHEN a player joins a game through the games repository THEN the players repository and the notifications repository see the change (one shared store).
- AC3 (steps 4-7, unit tests): each controller added has a test with a fake repository covering one success and one failure of its main command.
- AC4 (steps 4-7, widget tests): the smoke test and the Q1 design tests pass unchanged for every screen touched.
- AC5 (every step, gate): `arch_lint.py` reports 0 problems, and after step 7 `arch_lint.py --all` prints no `known` line.
- AC6 (step 7, gate): `grep -rn "RepositoryProvider" app/lib --include="*_screen.dart" --include="*_sheet.dart"` and the same search in `widgets/` folders find nothing.
- AC7 (steps 2 and 7, gate): `flutter analyze` is clean with the two lints of rule 8 switched on.

## Out of scope

New screens, new behaviour, changes to SQL, renaming features or routes,
golden image tests.
