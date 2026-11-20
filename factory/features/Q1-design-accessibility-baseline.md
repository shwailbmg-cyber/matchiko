---
id: Q1
title: Design and accessibility baseline tests
release: R1
order: 10
kind: build
status: ready
risk: low
surfaces: []
depends_on: []
sources: [.claude/skills/matchiko-design/SKILL.md, docs/FACTORY.md#gate]
---

# Q1 Design and accessibility baseline tests

## Goal

Every screen is checked by tests for tap-target size, labels, contrast and
large text, in English and Arabic, so later features cannot quietly break
the design rules. After this feature the gate enforces them.

## Rules

1. The checks use Flutter's own guidelines from `flutter_test`:
   `androidTapTargetGuideline` (48×48), `labeledTapTargetGuideline`,
   `textContrastGuideline`.
2. They run on every screen the smoke test already opens (player and
   manager), in `en` and in `ar` (RTL).
3. No screen overflows at text scale 1.3; the five main player screens
   (home, pitch, game, play, profile) do not overflow at 2.0.
4. A violation is fixed in the app (bigger hit area, a semantics label, a
   token with enough contrast). No rule is switched off globally.
5. If a fix needs a design decision, the screen goes in a `knownGaps` map
   in the test with a one-line reason. At most 5 entries.

## Steps

- [ ] 1. **app** Add `app/test/design/guidelines_test.dart`: one helper that pumps a screen (reusing `test/helpers.dart`) and expects the three guidelines; cover every screen of the smoke test in `en` and `ar`. Fix the violations it finds.
- [ ] 2. **ui** Add `app/test/design/text_scale_test.dart`: all smoke-test screens at text scale 1.3, the five main player screens at 2.0, no overflow errors. Fix the layouts that overflow (Flexible, wrapping, scrolling), keeping the look at scale 1.0.

## Acceptance criteria

- AC1 (step 1, widget test): GIVEN each smoke-test screen in `en` and `ar` WHEN pumped THEN it meets the three guidelines, or is listed in `knownGaps` with a reason (≤ 5 entries).
- AC2 (step 2, widget test): GIVEN text scale 1.3 WHEN each smoke-test screen is pumped THEN no overflow error is reported.
- AC3 (step 2, widget test): GIVEN text scale 2.0 WHEN home, pitch, game, play and profile are pumped THEN no overflow error is reported.
- AC4 (both steps): `flutter test` is green and the existing smoke test is unchanged in what it covers.

## Out of scope

Golden image tests (a later feature, once the missing screens are designed).
New visual design.
