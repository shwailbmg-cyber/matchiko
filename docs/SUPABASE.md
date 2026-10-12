# Supabase project

Project **matchiko** (`eehviixaazixayquzurd`), region Paris (`eu-west-3`),
free plan. App config: `app/env/dev.json` (URL + publishable key, public).

## Deploying the database

Migrations and the `push` Edge Function go out through the GitHub workflow
**Deploy Supabase** (Actions tab → Run workflow).

One-time setup, repo Settings → Secrets and variables → Actions:

| Secret | Where |
|---|---|
| `SUPABASE_DB_URL` | Dashboard → **Connect** → **Session pooler** → copy the URI, replace `[YOUR-PASSWORD]` with the database password |
| `SUPABASE_ACCESS_TOKEN` | supabase.com/dashboard/account/tokens (`sbp_…`), only needs Edge Functions: Read-write |

The password must be URL-safe inside the URI: if it contains `@ : / ? # %`,
reset it (Database → Settings) to letters and digits only.

- **First run:** tick **reset** (the project was half-loaded during setup;
  this wipes it and loads every migration cleanly). Only safe while there
  is no real data.
- **After that:** run it without reset whenever a new migration is merged;
  it applies only the new ones.

Then finish push notifications with `docs/PUSH.md` § 2 (secrets, webhook,
pg_cron).
