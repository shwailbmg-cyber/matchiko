#!/usr/bin/env bash
# Runs migrations, seed and pgTAP tests on a throwaway local Postgres (no
# Docker needed). Needs postgresql + postgresql-<ver>-pgtap installed.
# Prefer `supabase db reset && supabase test db` when Docker is available.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PGBIN="${PGBIN:-$(ls -d /usr/lib/postgresql/*/bin | sort -V | tail -1)}"
DATA="$(mktemp -d)"
PORT="${PGPORT:-54329}"
RUN_AS=()
if [ "$(id -u)" = 0 ]; then
  chown postgres "$DATA"
  RUN_AS=(runuser -u postgres --)
fi

cleanup() { "${RUN_AS[@]}" "$PGBIN/pg_ctl" -D "$DATA" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$DATA"; }
trap cleanup EXIT

"${RUN_AS[@]}" "$PGBIN/initdb" -D "$DATA" -U postgres -A trust >/dev/null
"${RUN_AS[@]}" "$PGBIN/pg_ctl" -D "$DATA" -o "-p $PORT -k /tmp -c TimeZone=UTC -c wal_level=logical" -w start >/dev/null

PSQL=("$PGBIN/psql" -h /tmp -p "$PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -q)
"${PSQL[@]}" -f "$ROOT/tests/local/supabase_shim.sql"
for f in "$ROOT"/migrations/*.sql; do
  echo "migrate  $(basename "$f")"
  "${PSQL[@]}" -f "$f"
done
echo "seed     seed.sql"
"${PSQL[@]}" -f "$ROOT/seed.sql"

status=0
for f in "$ROOT"/tests/database/*.sql; do
  echo "test     $(basename "$f")"
  out="$("${PSQL[@]}" -X -t -A -c 'set search_path = public, extensions' -f "$f" 2>&1)" || status=1
  echo "$out" | sed 's/^/  /'
  if echo "$out" | grep -qE '^not ok|Looks like you failed|ERROR'; then status=1; fi
done
exit $status
