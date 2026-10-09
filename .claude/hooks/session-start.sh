#!/bin/bash
# Installs what cloud sessions need to run `flutter analyze`, `flutter test`
# and the database tests (supabase/tests/local/run.sh). Idempotent.
set -euo pipefail

if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

FLUTTER_VERSION=3.47.7
SDK_DIR=/opt/sdk
FLUTTER="$SDK_DIR/flutter/bin/flutter"

# Flutter SDK
if [ ! -x "$FLUTTER" ] || ! "$FLUTTER" --version 2>/dev/null | grep -q "Flutter $FLUTTER_VERSION"; then
  rm -rf "$SDK_DIR/flutter"
  mkdir -p "$SDK_DIR"
  curl -sSfL "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" \
    | tar -xJ -C "$SDK_DIR"
fi
git config --global --add safe.directory "$SDK_DIR/flutter" 2>/dev/null || true
"$FLUTTER" --disable-analytics >/dev/null 2>&1 || true
echo "export PATH=\"$SDK_DIR/flutter/bin:\$PATH\"" >> "$CLAUDE_ENV_FILE"

# App dependencies + generated localizations
(cd "$CLAUDE_PROJECT_DIR/app" && "$FLUTTER" pub get >/dev/null)

# pgTAP for the plain-Postgres database tests
PGVER=$(ls /usr/lib/postgresql 2>/dev/null | sort -V | tail -1)
if [ -n "$PGVER" ] && ! ls "/usr/share/postgresql/$PGVER/extension/" 2>/dev/null | grep -q '^pgtap.control$'; then
  apt-get install -y "postgresql-$PGVER-pgtap" >/dev/null 2>&1 \
    || (apt-get update >/dev/null 2>&1 && apt-get install -y "postgresql-$PGVER-pgtap" >/dev/null 2>&1) \
    || echo "warning: could not install pgtap; database tests unavailable" >&2
fi
