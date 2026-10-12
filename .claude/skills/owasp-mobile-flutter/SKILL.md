---
name: owasp-mobile-flutter
description: OWASP mobile security for Flutter apps - OWASP Mobile Top 10 (2024) and MASVS v2 control groups mapped to concrete Flutter/Dart and Supabase checks. Use when reviewing or writing Flutter code that touches storage, tokens, auth, network, deep links, permissions, WebViews, logging, release builds or new packages; or when asked for a mobile security review, MASVS or Mobile Top 10 check.
---

# OWASP mobile security for Flutter

Use with `owasp-security` (web/API, ASVS 5.0) and `matchiko-security`
(project rules). This file is the mobile layer: what the app on the phone
must and must not do. The server is the real gate; the app only reduces
leaks and misuse.

## Review workflow

1. List what the diff touches: storage, auth/session, network, deep links,
   permissions, platform channels, logging, build config, dependencies.
2. Walk only the matching sections below.
3. For each candidate, check it is reachable on a real device (rooted phone,
   intercepted traffic, malicious app on the same phone, stolen unlocked phone).
4. Report: `[SEVERITY] title (M#, MASVS-XXX) · file:line · impact · fix`.
   Nothing exploitable → say so. No padding.

## Mobile Top 10 (2024) → Flutter checks

| # | Risk | Check in Flutter |
|---|---|---|
| M1 | Improper Credential Usage | No secrets in Dart code, `--dart-define`, assets or `env/*.json` (only the Supabase URL + publishable key). Service-role keys never in the app. |
| M2 | Inadequate Supply Chain Security | New package: verified publisher, recent release, no OSV advisory, few transitive deps. `pubspec.lock` committed. CI actions pinned by SHA. |
| M3 | Insecure Authentication/Authorization | Roles, prices, statuses decided server-side (RLS + RPC). Client role checks are UX only. Sign-out clears every session (Supabase + Google). |
| M4 | Insufficient Input/Output Validation | Validate deep-link and QR payloads before use. Never build SQL/filters from raw strings; use RPC params. No HTML rendering of user text. |
| M5 | Insecure Communication | HTTPS only: `android:usesCleartextTraffic="false"`, no `badCertificateCallback` returning true, no ATS exceptions. |
| M6 | Inadequate Privacy Controls | Collect the minimum. Phone numbers and exact location of others never shown. Location "while in use" only. Delete-account path exists. |
| M7 | Insufficient Binary Protections | Release: `--obfuscate --split-debug-info`. Assume the APK is read: nothing in it should matter. |
| M8 | Security Misconfiguration | `android:exported` set on purpose, `allowBackup="false"` (or backup rules excluding tokens), no debug flags in release, minimal permissions. |
| M9 | Insecure Data Storage | Tokens and refresh tokens in `flutter_secure_storage` (Keystore/Keychain). `shared_preferences` only for non-sensitive prefs (language, theme). No PII in files or caches. |
| M10 | Insufficient Cryptography | No home-made crypto. Use platform/Supabase. Hash IDs server-side (keyed hash in Postgres), never in Dart. |

## MASVS v2 control groups

- **MASVS-STORAGE**: secure storage for secrets; no sensitive data in logs
  (`debugPrint`/`print` of tokens, phone, ID), screenshots of ID screens
  avoided, clipboard only for non-sensitive text (invite links).
- **MASVS-CRYPTO**: keys never hard-coded; platform keystore only.
- **MASVS-AUTH**: server-side sessions (Supabase JWT); OTP codes rate-limited
  server-side; re-auth for phone/email change; no auth decisions on device.
- **MASVS-NETWORK**: TLS everywhere; pinning not needed for v1 (Supabase
  rotates certs) - revisit for payments.
- **MASVS-PLATFORM**: deep links (`go_router` routes) never perform an action
  without user confirmation; no `WebView` JS bridges; permission prompts
  only at the moment of use (camera on scan screen).
- **MASVS-CODE**: `flutter analyze` clean, dependencies up to date, no
  `dart:mirrors`/dynamic code, errors fail closed with a generic message.
- **MASVS-RESILIENCE**: defense in depth only; tampered local state must not
  unlock anything the server would refuse.
- **MASVS-PRIVACY**: data minimisation, clear purpose for each permission,
  user can export/delete their data.

## Quick grep list

```bash
grep -rnE "print\(|debugPrint\(" app/lib | grep -iE "token|phone|password|session|id_"
grep -rn "badCertificateCallback" app/lib
grep -rn "usesCleartextTraffic\|allowBackup\|exported" app/android/app/src/main/AndroidManifest.xml
grep -rnE "service_role|sk_live|secret" app/lib app/env 2>/dev/null
```

Sources: OWASP Mobile Top 10 2024 (owasp.org/www-project-mobile-top-10),
OWASP MASVS v2 (mas.owasp.org/MASVS).
