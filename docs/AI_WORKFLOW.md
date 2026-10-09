# Working on Matchiko with Claude Code (and spending less)

## The model split (already configured)

| Work | Model | How it's wired |
|---|---|---|
| Analysis, specs, plans, hard design | **Opus** | `"model": "opusplan"` in `.claude/settings.json`: plan mode runs on Opus. Also the `architect` subagent. |
| Writing code, migrations, tests | **Sonnet** | `opusplan` switches to Sonnet when you leave plan mode. Also the `implementer` subagent, and any subagent without its own model (`CLAUDE_CODE_SUBAGENT_MODEL=sonnet`). |
| Running commands, searching files | **Haiku** | `runner` subagent (tests, analyze, format, git), plus a Haiku `Explore` override for code search. |

Subagents live in `.claude/agents/`. A subagent's own `model:` wins over the
env default. Sources: [model config](https://code.claude.com/docs/en/model-config), [subagents](https://code.claude.com/docs/en/sub-agents).

## The loop for each feature

```
1. Plan (Opus)       Shift+Tab into plan mode → "Plan M2: pitch booking"
                     → approve the plan (save big ones to docs/plans/).
2. Build (Sonnet)    Leave plan mode; it implements on Sonnet.
                     Or: "use the implementer agent on docs/plans/m2.md".
3. Check (Haiku)     "use the runner agent: flutter analyze, flutter test,
                     supabase/tests/local/run.sh"
4. Review (Opus)     /code-review on the diff, and the matchiko-security skill.
5. /clear            Fresh context before the next feature.
```

This is plan-then-execute. "Ralph"-style loops (re-running the same prompt
until a check passes) trade many more tokens for less babysitting. They only
pay off with a precise spec and strict tests, so use them later, if at all,
with a hard `--max-iterations` cap. ([Shipyard](https://shipyard.build/blog/claude-code-ralph-loop/), [DreamHost](https://www.dreamhost.com/blog/ralph-wiggum/))

## Habits that save the most

- **`/clear` between unrelated tasks.** A long conversation is re-read on
  every turn, which makes it the biggest cost.
- **Point at files.** "Change `app/lib/routing/router.dart`" is cheaper than
  "find where routing happens".
- **One milestone per session**, with the plan in a file, so a new session
  starts from the plan instead of the chat history.
- **Don't fan out tiny tasks to subagents.** Each one starts with ~25–35k
  tokens of context; one is worth it for a big search or a separate review.
- **Lower effort for routine work:** `/effort low` for renames and
  formatting, `high` for design. Sonnet/Haiku 5.5 default to `medium`.
- **Keep CLAUDE.md short.** It loads every turn. Skills load only when used,
  so detailed guides belong in skills, not CLAUDE.md.
- Turn off **ultracode/workflows** unless you want large parallel runs.
