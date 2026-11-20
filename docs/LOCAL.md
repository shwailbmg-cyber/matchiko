# Working on your own computer (Android Studio)

The project was built in Claude Code on the web. Everything it needs is in
the repository, so the same factory runs from Android Studio.

## 1. Install (once)

| What | Why | How |
|---|---|---|
| Git | get the code, push branches | git-scm.com (on Windows this also gives Claude a Bash shell) |
| Flutter 3.47.7 | build and test the app | flutter.dev, then `flutter doctor` |
| Android Studio + Flutter plugin | run the app on a phone or emulator | Settings → Plugins → "Flutter" |
| Python 3 | the factory's scripts | python.org (tick "Add to PATH" on Windows) |
| Claude Code | the agent | macOS/Linux: `curl -fsSL https://claude.ai/install.sh \| bash` · Windows PowerShell: `irm https://claude.ai/install.ps1 \| iex` · then `claude --version` |
| Claude Code plugin for JetBrains | Claude inside Android Studio | Settings → Plugins → Marketplace → "Claude Code [Beta]" (publisher Anthropic), restart |
| GitHub CLI `gh` | open pull requests | cli.github.com, then `gh auth login` |
| Docker Desktop + Supabase CLI | run the database tests | docker.com · supabase.com/docs/guides/cli · only needed for features that change the database |

## 2. Open the project

```bash
git clone https://github.com/shwailbmg-cyber/matchiko
cd matchiko/app && flutter pub get
```

Open the `matchiko` folder in Android Studio. Press **Ctrl+Esc**
(**Cmd+Esc** on a Mac), or type `claude` in the Terminal tab. Claude reads
`CLAUDE.md`, the skills, the agents and the factory from the repo by
itself.

First check that the machine can run the gate:

```bash
python3 factory/bin/factory status          # python on Windows
FACTORY_BASE=origin/main bash factory/checks.sh
```

## 3. Drive the factory

Type in Claude: `/factory status`, `/factory run`, `/factory plan G3`
(see `docs/FACTORY.md`). Run the app on your phone from Android Studio to
look at what each pull request built before you merge it:

```bash
cd app && flutter run --dart-define-from-file=env/dev.json
```

## 4. What is different from the web sessions

- **Connectors** set up on claude.ai (Supabase, Figma…) do not exist
  locally. Database changes go out through the GitHub workflow
  **Deploy Supabase**, as before; nothing else is needed.
- **Permissions**: Claude asks before running commands. To let it edit
  files without asking each time, press Shift+Tab to "accept edits". The
  JetBrains docs advise keeping manual approval for commands inside an
  IDE; the factory's checks still protect the repo either way.
- **The nightly cloud run** (below) and your computer are two separate
  sessions that meet only through GitHub. Before working locally:
  `git fetch origin`. The factory skill already skips a feature another
  session touched in the last 30 minutes.
- The database tests use Docker here instead of the plain-Postgres
  runner used in the cloud. This path was not tried from the cloud
  session that wrote it: if it fails on your machine, tell Claude the
  error.

## 5. The nightly run

A scheduled Claude Code task can start a cloud session every night with
the factory. It builds what is ready on `main`, opens pull requests, and
when nothing is ready it writes the plan of the next draft feature for
you to approve. You find the result in the morning: pull requests to
merge and questions to answer. **It is not created yet:** follow
`factory/NIGHTLY.md` (two minutes, one prompt to paste).

## 6. What still needs you

The factory cannot merge for you (unless you turn `auto_merge` on),
decide product questions, test on a real phone, create the Firebase /
Play / Apple accounts, or sign the release. `python3 factory/bin/factory
status` always shows what is waiting for you (`WAIT` and `HUMAN` lines).
