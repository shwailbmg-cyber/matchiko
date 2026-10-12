# Push notifications setup

The server writes every notification into `public.notifications`
(triggers + `send_reminders()`). A Database Webhook sends each new row to
the `push` Edge Function, which pushes it to the user's phones through
Firebase Cloud Messaging (FCM). The app only registers its device token.

Without the steps below everything still works: the in-app inbox fills,
there is just no push.

## 1. Firebase (once, about 15 minutes)

1. console.firebase.google.com → **Add project** (Analytics not needed).
2. **Add app → Android** (not "Flutter": the app reads its keys from env,
   so you don't need the FlutterFire CLI or any config file).
   Package name `dz.bmgdev.matchiko`. Skip the `google-services.json`
   download and the SDK steps.
3. **Add app → iOS** in the same project. Bundle ID `dz.bmgdev.matchiko`.
   Skip the `GoogleService-Info.plist` download and the SDK steps.
4. Project settings → **General**. Copy into `app/env/dev.json` (public
   client values, safe in the app):

   | env key | where |
   |---|---|
   | `FIREBASE_PROJECT_ID` | top of the page, "Project ID" |
   | `FIREBASE_SENDER_ID` | Cloud Messaging tab, "Sender ID" (= project number) |
   | `FIREBASE_ANDROID_API_KEY` | Android app → "Web API Key" / API key |
   | `FIREBASE_ANDROID_APP_ID` | Android app → "App ID" (`1:…:android:…`) |
   | `FIREBASE_IOS_API_KEY` | iOS app → API key |
   | `FIREBASE_IOS_APP_ID` | iOS app → "App ID" (`1:…:ios:…`) |

   The API keys are also in each app's downloaded config file
   (`api_key` / `API_KEY`) if the page doesn't show them.
5. Project settings → **Service accounts → Generate new private key**.
   This JSON is a **secret**: never commit it, never put it in the app.

### iOS only: Apple push key (needs the paid Apple Developer account)

6. developer.apple.com → Certificates, IDs & Profiles → **Keys → +** →
   tick **Apple Push Notifications service (APNs)** → download the `.p8`
   file (only once!) and note the **Key ID** and your **Team ID**.
7. Firebase → Project settings → **Cloud Messaging → Apple app
   configuration → APNs Authentication Key → Upload** the `.p8` with the
   Key ID and Team ID.
8. In Xcode (`app/ios/Runner.xcworkspace`) → Runner target → **Signing &
   Capabilities → + Capability → Push Notifications**. (Background mode
   "Remote notifications" is already set in `Info.plist`.)

Android needs nothing more.

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
