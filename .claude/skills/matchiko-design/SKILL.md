---
name: matchiko-design
description: Matchiko's design rules for Flutter screens - tokens, spacing, type, components, states, motion, RTL, accessibility and low-end performance, each one checkable. Use when building or reviewing any screen, widget, sheet or card in app/lib, when a design looks off, or when the factory's design reviewer runs.
---

# Matchiko design rules

The look is fixed by the prototype (`design/prototype/Matchiko.html`,
`BRIEF.md`) and the tokens in `app/lib/core/theme/`. This skill is how to
stay inside it. Every rule is checkable; cite the rule id in a review.

Fixed choices, do not ask: **WCAG 2.2 level AA**, platforms **Android and
iOS**, dark theme only, languages EN / FR / AR (Arabic is RTL). For a deep
accessibility audit use the `accessibility` skill with those answers.

## Workflow (building)

1. Find the screen in the prototype (`SC.<name>` in
   `design/prototype/*.js`). If it is not there, compose it from existing
   widgets; do not invent a new visual language.
2. Reuse first: `lib/core/widgets/` (`MkCard`, `MkTitle`, `MkLabel`,
   `MkTag`, `MkAvatar`, `AsyncView`, `MkEmpty`, nav bar) and
   `lib/shared/widgets/` (badges, ticket, pitch row…). A new shared widget
   needs two real uses.
3. Build the four states (loading, data, empty, error/offline) before the
   polish.
4. Check RTL and large text by test, not by eye (rules R and A).

## Tokens (T)

- **T1** Colours come from `MkColors`. No `Color(0x…)`, `Colors.*` or
  opacity-on-black outside `lib/core/theme/`. A missing colour is added as
  a named token, with its role in a comment.
- **T2** One role per colour: `primary` = the main action and active
  state; `sand` = rewards and warnings; `terra` = the opposing side;
  `red` = danger and errors; `turf` only on the pitch drawing.
- **T3** Radius from `MkRadius` (card 18, button 17, sheet 28). Chips and
  tags are fully round.
- **T4** Spacing on a 4-point grid: 4, 8, 12, 16, 20, 24, 32. Screen side
  padding is 20. No odd values (13, 22) unless the prototype has them.
- **T5** Type: display font (Barlow Condensed) for titles and numbers,
  body font (Cairo) for text and all Arabic. Sizes from the existing
  scale (11 label, 13–14 body, 16–18 emphasis, 24+ titles); body text
  never below 13.

## Layout (L)

- **L1** One filled primary button per screen or sheet, 56 high, at the
  bottom within thumb reach. Secondary actions are outlined or text.
- **L2** Tap targets at least 48×48, with 8 between neighbours. Small
  icons get padding, not a smaller target.
- **L3** Lists use `ListView.builder` / slivers; nothing that can grow
  sits in a plain `Column` inside a scroll view.
- **L4** Text that can be long (names, venues, translations) is in
  `Flexible`/`Expanded` with `maxLines` + ellipsis, or wraps. French is
  ~20 % longer than English.
- **L5** Bottom sheets for short choices; a full screen when there is a
  form with more than 4 fields.

## States (S)

- **S1** Every screen that loads data uses `AsyncView` (or the same four
  states): loading, data, empty with one way forward, error with retry
  and an offline message.
- **S2** A button that starts a request shows progress and is disabled
  until it ends; double taps cannot send twice.
- **S3** After an action the user sees the result (snackbar, changed
  state, navigation). No silent success, no silent failure.
- **S4** Destructive or costly actions (cancel a game, delete account,
  leave after confirmation) ask once, saying the cost in words.

## Right-to-left (R)

- **R1** Directional APIs only: `EdgeInsetsDirectional`,
  `AlignmentDirectional`, `PositionedDirectional`, `TextAlign.start/end`,
  `BorderRadiusDirectional`.
- **R2** Icons that point (arrows, chevrons, back) flip in RTL; numbers,
  times, codes, @handles and the logo stay LTR (`textDirection: ltr`).
- **R3** Every new screen is pumped in `ar` in a widget test with no
  overflow.

## Accessibility (A)

- **A1** Text contrast ≥ 4.5:1 (≥ 3:1 for text 18+ or bold 14+, icons and
  borders that carry meaning). `sub` and `faint` on `bg`/`card` are for
  secondary text only; never `faint` for something the user must read.
- **A2** Never colour alone: a status has a label or an icon as well.
- **A3** Every tappable has a label: visible text, `tooltip`, or
  `Semantics(label:)`. Decorative images are excluded from semantics.
- **A4** No overflow at text scale 1.3 on any screen and 2.0 on the main
  ones; no fixed-height box around text.
- **A5** Tested with `meetsGuideline(androidTapTargetGuideline)`,
  `labeledTapTargetGuideline` and `textContrastGuideline`
  (`app/test/design/`, feature Q1).

## Motion (M)

- **M1** 150–200 ms for small changes, 250–350 ms for sheets and page
  changes; nothing over 600 ms. Standard curves (`easeOut` in,
  `easeIn` out).
- **M2** Motion explains a change (a spot filled, a status moved); no
  decoration loops except the search radar.
- **M3** Respect `MediaQuery.disableAnimations`.

## Performance on low-end phones (P)

- **P1** `const` constructors wherever possible; no work in `build`
  beyond layout (no sorting, parsing, date maths on long lists).
- **P2** Images sized to their box (`cacheWidth`/`cacheHeight`), JPEG/WebP,
  placeholders by initials or colour, never a spinner per image.
- **P3** No `Opacity`/`ClipRRect`/blur over large moving areas; no
  `saveLayer`-heavy effects in lists.
- **P4** No new package for a visual effect that 20 lines of Flutter can
  draw.

## Words (W)

- **W1** All text from `app_en/fr/ar.arb`. Simple words, B2 level,
  standard French and Arabic, football terms from `docs/GAMES.md` § 10.
- **W2** Buttons say the action ("Book this hour"), not "OK". Errors say
  what happened and what to do next.
- **W3** Numbers with units (DA, min, km); prices in 50 DA steps; times in
  24 h format.

## Review output

For each problem: rule id · file:line · what the user sees · the fix (as
code when short). If nothing breaks a rule, say so plainly. Do not report
taste; report rules.
