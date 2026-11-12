#!/usr/bin/env bash
# The gate: exit 0 only when the branch is fit to review.
#
# Run by `factory/bin/factory gate <ID>` from the repo root, using the base
# branch's copy of this file, so a branch cannot weaken the checks it is
# judged by. Deterministic and non-interactive. The same checks can be run
# by hand:  FACTORY_BASE=origin/main bash factory/checks.sh
set -euo pipefail

BASE="${FACTORY_BASE:-origin/main}"
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
export PATH="/opt/sdk/flutter/bin:$PATH"   # cloud sessions; harmless elsewhere
PY="$(command -v python3 || command -v python)" || { echo "Python 3 is needed."; exit 1; }
# Where this branch left the base. Cloud checkouts are shallow, so fetch
# more history when the common ancestor is not there yet.
FROM="$(git merge-base "$BASE" HEAD 2>/dev/null || true)"
for depth in 200 2000; do
  [ -n "$FROM" ] && break
  git fetch -q --deepen="$depth" origin 2>/dev/null || true
  FROM="$(git merge-base "$BASE" HEAD 2>/dev/null || true)"
done
[ -n "$FROM" ] || { echo "No common ancestor with $BASE; fetch more history."; exit 1; }
changed() { git diff --name-only "$FROM" HEAD -- "$@" | grep -q .; }
step() { echo; echo "── $* ──"; }

step "factory: feature files and its own tests"
"$PY" factory/bin/factory validate
"$PY" -m unittest discover -s factory/tests -q

step "lints on the lines this branch adds (design, RTL, security, SQL rules)"
"$PY" factory/lints/diff_lint.py "$FROM"

step "architecture: layers, imports, file and function sizes"
"$PY" factory/lints/arch_lint.py

step "translations: en / fr / ar have the same keys"
"$PY" factory/lints/l10n_check.py

cd app
step "flutter pub get + gen-l10n"
flutter pub get >/dev/null
flutter gen-l10n >/dev/null

if changed app/lib; then
  step "generated code is up to date (build_runner)"
  dart run build_runner build -d >/dev/null
  git diff --exit-code --stat -- lib || {
    echo "Generated files are stale: run 'dart run build_runner build -d' and commit."
    exit 1
  }
fi

step "dart format"
dart format --set-exit-if-changed -o none lib test

step "flutter analyze"
flutter analyze

step "flutter test"
flutter test

cd "$ROOT"
if changed supabase; then
  step "database tests (pgTAP)"
  LOG="$(mktemp)"
  if ls /usr/lib/postgresql/*/bin/initdb >/dev/null 2>&1; then
    # Linux with Postgres + pgTAP installed (cloud sessions, CI): no Docker needed.
    bash supabase/tests/local/run.sh >"$LOG" 2>&1 || { tail -40 "$LOG"; exit 1; }
  elif command -v supabase >/dev/null 2>&1; then
    # A developer machine: the Supabase CLI with Docker (docs/LOCAL.md).
    { supabase start && supabase db reset && supabase test db; } >"$LOG" 2>&1 || { tail -40 "$LOG"; exit 1; }
  else
    echo "Database files changed but no way to test them here."
    echo "Install the Supabase CLI and Docker (docs/LOCAL.md), or Postgres with pgTAP on Linux."
    exit 1
  fi
  grep -c "^ *ok " "$LOG" | sed 's/$/ database assertions passed/'
fi

echo
echo "All checks passed."
