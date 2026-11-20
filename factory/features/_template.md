---
id: X0
title: Short title
release: R1            # R1 | R2 | R3
order: 999             # build order inside the release (lower first)
kind: build            # build | human (a task only the owner can do; never blocks)
status: draft          # draft | ready | done | blocked
risk: medium           # low | medium | high (routes reviewers and models)
surfaces: []           # security → a security review on every step
depends_on: []         # feature ids that must be merged first
sources: []            # where the rules come from, e.g. docs/GAMES.md#3
---

# X0 Short title

## Goal

One or two sentences: who gets what, and why it matters.

## Rules

The behaviour, as decided. Numbered, each one checkable. Link the decision
(docs/GAMES.md § …). Write what must be true, not how to code it.

1. …

## Steps

One step = one small, shippable change with its own tests. The tag routes
reviewers: **db** (migration + pgTAP), **app** (models, repositories,
providers), **ui** (screens, l10n), **edge** (Edge Functions), **docs**.
Only the factory ticks these boxes.

- [ ] 1. **db** …
- [ ] 2. **app** …
- [ ] 3. **ui** …

## Acceptance criteria

Numbered; each says how it is verified (pgTAP test, widget test, unit test).
A step is done only when the criteria it names pass.

- AC1 (step 1, pgTAP): GIVEN … WHEN … THEN …

## Out of scope

What this feature does not do (and which feature does).

## Open questions

Anything only the owner can answer. A feature with open questions stays
`draft`.
