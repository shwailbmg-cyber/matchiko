# Testing Matchiko on a real phone

Two Android builds are on the **preview** release
(github.com/shwailbmg-cyber/matchiko/releases/tag/preview), rebuilt on every
merge to `main`:

- `matchiko-demo.apk`: sample data, no account. Same as the web demo.
- `matchiko-live.apk`: the real Supabase project, real accounts, push.

iPhone: needs a Mac + Xcode (or TestFlight later); test on Android first.

## 0. One-time: sign-in emails send a 6-digit code

Supabase dashboard → Authentication → **Emails** → Templates. In both
**Confirm signup** and **Magic Link**, set the body to:

```html
<h2>Matchiko</h2>
<p>Votre code / رمزك / Your code:</p>
<p style="font-size:28px;font-weight:bold;letter-spacing:4px">{{ .Token }}</p>
<p>Valable 1 heure. Si vous n'avez rien demandé, ignorez cet e-mail.<br>
صالح لمدة ساعة. إذا لم تطلب هذا الرمز، تجاهل هذه الرسالة.<br>
Valid for 1 hour. If you did not ask for it, ignore this email.</p>
```

The built-in mailer sends only a few emails per hour: enough to test,
not to launch (add your own SMTP under Authentication → SMTP later).

## 1. Accounts

You need two email addresses: **A** = player, **B** = stadium manager.

1. Install `matchiko-live.apk`, sign in with **A**, finish onboarding
   (name, wilaya, positions, phone).
2. Sign out (Settings → Log out), sign in with **B**, finish onboarding.
3. Tell Claude both emails: it verifies **A** (normally done in person
   at a stadium) and creates a test venue managed by **B**.

## 2. The main loop

| # | Who | Do | Expect |
|---|---|---|---|
| 1 | A | Home → pick the test pitch → book a free hour | Game "Requested" in Matches |
| 2 | A | Open the game → **Ticket** | QR code + a code under it |
| 3 | B | Today → the request → **Confirm** | A gets a push "Booking confirmed" |
| 4 | B | Scan → Booking → camera on A's QR (or **Type the code**) → cash received → Guaranteed | Status "Guaranteed" on both phones |
| 5 | A | Profile → **My QR code**; B: Scan → Arrival → scan it | "A arrived" |
| 6 | A | Game page → open the game to others | B's friends get "A spot is open" |
| 7 | — | 2–3 h before kick-off | Players get "Still coming?" |

With one phone, switch accounts between steps (log out / in) and use
**Type the code** instead of the camera.

## 3. When something fails

Note the step number and the message on screen and send it to Claude.
Logs: Supabase dashboard → Logs (API, Postgres, Edge Functions → `push`).
