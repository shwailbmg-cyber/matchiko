#!/usr/bin/env bash
# Regenerates app/test/fixtures/game_json.json from real public.game_json()
# output, so the Dart contract test follows the SQL. Plain Postgres, as root
# or as a user who can run `runuser -u postgres`.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
PGBIN="${PGBIN:-$(ls -d /usr/lib/postgresql/*/bin | sort -V | tail -1)}"
DATA="$(mktemp -d)"; PORT="${PGPORT:-54331}"
chown postgres "$DATA"
RUN=(runuser -u postgres --)
cleanup() { "${RUN[@]}" "$PGBIN/pg_ctl" -D "$DATA" stop -m immediate >/dev/null 2>&1 || true; rm -rf "$DATA"; }
trap cleanup EXIT
"${RUN[@]}" "$PGBIN/initdb" -D "$DATA" -U postgres -A trust >/dev/null
"${RUN[@]}" "$PGBIN/pg_ctl" -D "$DATA" -o "-p $PORT -k /tmp -c TimeZone=UTC -c wal_level=logical" -w start >/dev/null
PSQL=("$PGBIN/psql" -h /tmp -p "$PORT" -U postgres -d postgres -v ON_ERROR_STOP=1 -q -X -t -A)
"${PSQL[@]}" -f "$ROOT/tests/local/supabase_shim.sql" >/dev/null
for f in "$ROOT"/migrations/*.sql; do "${PSQL[@]}" -f "$f" >/dev/null; done
"${PSQL[@]}" -f "$ROOT/seed.sql" >/dev/null
"${PSQL[@]}" >/dev/null <<'SQL'
select set_config('request.jwt.claims', '{"sub":"00000000-0000-0000-0000-0000000000a1","role":"authenticated"}', false);
select public.request_booking('00000000-0000-0000-0000-00000000b001', timestamptz '2026-10-20 20:00:00+00');
SQL
"${PSQL[@]}" -c "select set_config('request.jwt.claims', '{\"sub\":\"00000000-0000-0000-0000-0000000000a1\",\"role\":\"authenticated\"}', false) is null" \
  -c "select jsonb_set(jsonb_set(g, '{id}', '\"00000000-0000-0000-0000-0000000000d1\"'), '{code}', '\"e310ff9e1a1697049459495fbb481be8\"') from public.my_games() g limit 1" \
  | tail -n 1 | python3 -c "import json,sys; print(json.dumps(json.loads(sys.stdin.read()), ensure_ascii=False, indent=2))" \
  > "$ROOT/../app/test/fixtures/game_json.json"
echo "wrote app/test/fixtures/game_json.json"
