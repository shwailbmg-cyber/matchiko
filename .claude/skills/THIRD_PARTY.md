# Vendored agent skills

These skills are copied from their official upstream repos so they load
automatically in every Claude Code session (local and cloud) without
installing plugins. Each one keeps the license of its source repo.
To update one, re-copy the folder from the upstream commit you want and bump the
commit hash here.

| Skills | Upstream | Commit | License |
|---|---|---|---|
| `flutter-*` | [flutter/agent-plugins](https://github.com/flutter/agent-plugins) | 0ef3972 | BSD-3-Clause |
| `dart-*` | [dart-lang/skills](https://github.com/dart-lang/skills) | 0d9f1c4 | BSD-3-Clause |
| `supabase`, `supabase-postgres-best-practices` | [supabase/agent-skills](https://github.com/supabase/agent-skills) | c9be0e9 | MIT |
| `differential-review`, `sharp-edges`, `semgrep`, `supply-chain-risk-auditor`, `agentic-actions-auditor` | [trailofbits/skills](https://github.com/trailofbits/skills) | 82fe822 | CC BY-SA 4.0 (the copied files stay under CC BY-SA 4.0) |
| `matchiko-security` | written for this project | — | same as this repo |

## Not vendored on purpose

- **Flutter plugin's Dart MCP server**: install it locally with
  `/plugin marketplace add flutter/agent-plugins` then
  `/plugin install dart-flutter@dart-flutter`. It needs a running Dart SDK and
  gives the agent runtime-error and widget-tree tools.
- **Trail of Bits `codeql`**: CodeQL has no Dart support.
- **Community OWASP mobile scanners** (e.g. harishwarrior/flutter-claude-skills):
  they ship unaudited Python scripts. `matchiko-security` covers the
  OWASP MASVS checks we need instead.
