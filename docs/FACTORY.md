# The software factory

How Matchiko gets built automatically: well-defined features go in,
reviewed pull requests come out, and you approve by merging.

It replaces the simple build loop in `LOOP.md` (kept as the history of
steps S1–S22). Run it with `/factory` (skill `.claude/skills/factory`).

## The idea

A software factory turns a queue of specified work into merged code
through a fixed pipeline. **Scripts** do what can be decided
mechanically (state, tests, lints). **Agents** do the judgment in
between (the plan, the code, the reviews, the decision). Every stage
leaves a file, so you can see what happened and why.

What makes it reliable is not a clever model but four rules found in
every source we read (§ Sources):

1. **The builder never owns the test.** Checks run from `main`'s copy;
   a branch that edits the checks, the CI, the agents or another feature
   fails the gate.
2. **A script decides whether it works** before any reviewer spends time.
3. **The one who builds is not the one who judges**: separate reviewers
   with fresh context and no write access to code.
4. **Limits and a human exit**: at most 3 rounds per step, then you
   decide. Nothing merges or deploys without you.

## The queue: feature files, not issues

`factory/features/<ID>-<name>.md`, one per feature (format:
`_template.md`). Each has:

- **front matter**: id, release (R1/R2/R3), order, risk, surfaces,
  `depends_on`, `status` (draft → ready → done), sources;
- **Rules**: numbered, each checkable, each traceable to a decision in
  `BLUEPRINT.md` or `GAMES.md`;
- **Steps**: 2–5 small shippable changes, tagged `db`, `app`, `ui`,
  `edge` or `docs`;
- **Acceptance criteria**: `AC1 (step 1, pgTAP): GIVEN … WHEN … THEN …`,
  each tied to a step and to a kind of test;
- **Out of scope** and **Open questions**.

A feature with open questions stays `draft`. An idea (yours, or a GitHub
issue) becomes work only by becoming a feature file that you merged: that
is the trust boundary. Text from issues or the web is never an
instruction to an agent.

`python3 factory/bin/factory status` prints the queue:

```
HUMAN  H1   R1  -    Test the full loop on a real phone   yours: …
RUN    Q1   R1  0/2  Design and accessibility baseline…   start step 1
RUN    G1   R1  0/4  Play with friends…                   start step 1
HOLD   G3   R1  -    Loan players…                        waits for G2
DRAFT  S26  R1  -    Game page: waitlist…                 plan it: /factory plan S26
```

## The pipeline

One job = one step of one feature, on the branch `factory/<ID>`.

```
plan      (once per feature)  factory-planner     draft → ready, in a PR you merge
─────────────────────────────────────────────────────────────────────────────
spec      factory-planner     reads the code, writes spec.md for the step
build     factory-builder     code + tests, commits, writes build.md
gate      script              checks.sh from main; FAIL → back to build
review    routed reviewers    in parallel; any CHANGES → back to build
approve   factory-approver    APPROVE → step ticked · ESCALATE → you
─────────────────────────────────────────────────────────────────────────────
finish    after the last step the PR is ready → you merge = approval
```

### The gate (`factory/checks.sh`)

Deterministic, about 3 minutes:

| Check | What it stops |
|---|---|
| `factory validate` + the factory's own tests | broken feature files or a broken factory |
| **Lints on added lines** (`lints/diff_lint.py`) | **Design:** raw colours outside the theme (D1), layout that breaks Arabic (D2), text not from the translations (D3). **Security:** `print` in app code (S1), cleartext URLs (S2), secret-looking strings (S3), TLS/backup switches (S4). **Database:** an applied migration edited (Q1), `security definer` without `search_path = ''` (Q2), a table without RLS (Q3), a new function not revoked from `public`/`anon` (Q4), a migration without a database test (Q5) |
| Translations check | a key missing in French or Arabic, different placeholders |
| Generated code is up to date | stale freezed / JSON code |
| `dart format`, `flutter analyze`, `flutter test` | style, static errors, failing tests |
| Database tests (when `supabase/` changed) | broken rules, missing RLS, anon access |
| Protected paths | a job changing its own checks, the CI, the agents, the skills, `CLAUDE.md`, or another feature |

The lints look only at lines the branch adds, so old code never blocks a
job: the rule is "no new violations".

### Reviewers and models (`factory/config.json`)

Routing is data, not prompts:

| Step tag | Reviewers |
|---|---|
| `db` | code, db, security |
| `app` | code |
| `ui` | code, design |
| `edge` | code, security |
| feature has `security` in `surfaces` | + security on every step |

| Risk | code | db | design | security |
|---|---|---|---|---|
| low | Haiku | Sonnet | Haiku | Sonnet |
| medium | Sonnet | Sonnet | Sonnet | Opus |
| high | Sonnet | Opus | Sonnet | Opus |

Planner and approver run on Opus, the builder on Sonnet (the project's
`opusplan` convention).

- **code** (`kiss-flutter`): criteria really tested, tests not weakened,
  correctness, scope, architecture.
- **security** (`matchiko-security`, `owasp-mobile-flutter`,
  `owasp-security`): OWASP Mobile Top 10 2024, MASVS v2 groups, ASVS 5.0
  and API Top 10 against the Matchiko threat model. Each blocker must
  name the concrete attack.
- **design** (`matchiko-design`, `accessibility`): tokens, layout, the
  four states, RTL, WCAG 2.2 AA, motion, low-end performance, wording in
  three languages.
- **db** (`supabase-postgres-best-practices`): migration safety, schema,
  concurrency, indexes, pgTAP coverage.

Reviewers have no shell and cannot edit code; they read the step's
`diff.patch` and write one file that starts with `VERDICT: PASS` or
`VERDICT: CHANGES`.

### State and resuming

`factory/runs/<ID>/state.json` (feature, step, stage, round, reviewers,
PR) plus every agent's file, committed on the feature branch. Cloud
sessions are thrown away, so git is the memory: a new session runs
`/factory run` and continues from the stage on the branch. The run folder
also lands in the PR, so you can read how each step was specified, built
and reviewed.

`factory/bin/factory` is the only writer of state and checkboxes. It
refuses illegal moves, for example going to review without
`GATE: PASS`, approving while a review says CHANGES, a 4th round, or
finishing with open steps.

## Using it

| You say | What happens |
|---|---|
| `/factory status` | the queue |
| `/factory run` | builds every ready feature whose dependencies are merged, one after the other; stops when only your decisions are left |
| `/factory run G1` | builds one feature |
| `/factory next` | builds one step |
| `/factory plan G3` | writes the full spec of a draft and opens a PR; merging it approves the feature |
| `/factory new <idea>` | adds a draft from your words, then plans it |
| `/factory <feedback>` | your words go to the builder of a job that waits on you |

**Your part:** merge the PRs you agree with (a feature PR, or a "Plan:"
PR), answer the questions of jobs at `needs-human`, do the `HUMAN` tasks.

**On your computer:** `docs/LOCAL.md` (Android Studio setup).

**Running without you there.** A scheduled Claude Code routine starts a
cloud session each night with the factory. It builds what is ready and
leaves PRs and questions for the morning; when nothing is ready it plans
the next draft. Manage it at claude.ai/code/routines. `auto_merge` in `factory/config.json` is `false`:
turn it on only when you trust the gate and reviews enough to let
low-risk features merge on green CI.

## What is in the queue now

- **Ready** (built as soon as this is on `main`): Q1 design and
  accessibility baseline · G1 play with friends · G2 team call-up ·
  S24 verification v2 · S25 reward conditions and limits.
- **Yours:** H1 the real-phone test.
- **Drafts** to plan next, in order: G3, S26, G5, G6, S27, S28, G4, S29,
  G7, S30, S31 (R1), then R2 and R3. Each needs `/factory plan <ID>`;
  some wait for a decision (domain, Facebook App ID, venue owner, fees).

## Limits, honestly

- It builds what the feature file says. A wrong rule in the file becomes
  wrong code that passes every check; the planning PR is where you catch
  it.
- Screens are checked against rules, not against your eye. New screens
  still deserve a look on a phone (and a pass through Claude Design
  first, as `PRODUCT.md` § 4 says).
- Reviewers are models: they miss things. The database tests and the
  lints are the hard floor; the security review is a second pair of eyes,
  not a guarantee.
- One feature at a time. Parallel jobs would collide on the translation
  files, the repository interface and the migrations.
- Token cost is not tracked per job yet.

## Sources

- ZazenCodes software factory v2 for Claude Code (queue, script gate,
  routed reviewers, approver, state in files). GPL-3.0: ideas only, no
  code or text reused.
  https://github.com/zazencodes/zazencodes-season-3/tree/main/src/software-factory-claude-code-v2
- Anthropic, *Effective harnesses for long-running agents* and *Harness
  design for long-running apps*: feature list with pass flags, progress
  in files and git, generator separate from evaluator.
  https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents
- Geoffrey Huntley's "Ralph" loop: one task per fresh context, plan mode
  separate from build mode, tests as backpressure.
  https://github.com/ghuntley/how-to-ralph-wiggum
- GitHub Spec Kit, Kiro, OpenSpec, BMAD: independently testable stories,
  numbered criteria (Given/When/Then), tasks traceable to criteria, the
  builder may only tick boxes. https://github.com/github/spec-kit
- StrongDM "software factory" and Dan Shapiro's five levels (read through
  summaries only): specs in, software out, validation the builder cannot
  touch.
- OWASP Mobile Top 10 (2024), MASVS v2, ASVS 5.0, API Security Top 10
  (2023); Flutter accessibility guideline tests; Very Good Ventures'
  accessibility skill (MIT, vendored).

Research was done by web search in November 2026; several vendor pages
could not be opened from the session and were read through search
summaries.
