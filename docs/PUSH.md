# Push notifications setup

The server writes every notification into `public.notifications`
(triggers + `send_reminders()`). A Database Webhook sends each new row to
the `push` Edge Function, which pushes it to the user's phones through
Firebase Cloud Messaging (FCM). The app only registers its device token.

Without the steps below everything still works: the in-app inbox fills,
there is just no push.

## 1. Firebase (once, about 10 minutes)

1. console.firebase.google.com → **Add project** (Analytics not needed).
2. **Add app → Android**, package `dz.bmgdev.matchiko`. You can skip the
   `google-services.json` download: the app reads its keys from env.
3. Project settings → General → your Android app: copy **API key**,
   **App ID**, **Project number** (= sender id) and **Project ID** into
   `app/env/dev.json`:
   `FIREBASE_API_KEY`, `FIREBASE_APP_ID`, `FIREBASE_SENDER_ID`,
   `FIREBASE_PROJECT_ID`. These are public client values.
4. Project settings → **Service accounts → Generate new private key**.
   This JSON is a **secret**: never commit it, never put it in the app.

## 2. Supabase

```bash
supabase functions deploy push
supabase secrets set FCM_SERVICE_ACCOUNT="$(cat service-account.json)"
supabase secrets set PUSH_WEBHOOK_SECRET="$(openssl rand -hex 32)"
```

Dashboard → **Database → Webhooks → Create**:
table `notifications`, event **Insert**, type **Supabase Edge Function**
`push`, header `x-webhook-secret` = the same secret.

Dashboard → **Database → Extensions**: enable `pg_cron`, then in the SQL
editor:

```sql
select cron.schedule('send-reminders', '*/15 * * * *', 'select public.send_reminders()');
```

## What gets pushed

| Kind | When | To |
|---|---|---|
| `booking_confirmed` | manager confirms | booker |
| `spot_open` | a game opens | booker's friends with "spots near you" on |
| `still_coming` | 2–3 h before kick-off | every player with reminders on |
| `rate_game` | booking completed | every player |
| `friend_request` | new request | the addressee |

Pushes carry only the kind and the game id; the text is built from the
user's language. Signing out deletes the device token.
