/// Build-time configuration, passed with `--dart-define-from-file=env/dev.json`.
///
/// Only public values belong here: the Supabase URL and the **publishable**
/// key (RLS protects the data). Never put a secret or service-role key in the
/// app. See `.claude/skills/matchiko-security/SKILL.md`.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabasePublishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// Google OAuth *web* client id (Supabase verifies tokens against it).
  /// Empty → the Google button is hidden and only email codes are offered.
  static const googleWebClientId = String.fromEnvironment(
    'GOOGLE_WEB_CLIENT_ID',
  );

  /// Firebase Cloud Messaging (push). Public client values from the
  /// Firebase console; empty → no push.
  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );

  static bool get hasFirebase =>
      firebaseApiKey.isNotEmpty &&
      firebaseAppId.isNotEmpty &&
      firebaseSenderId.isNotEmpty &&
      firebaseProjectId.isNotEmpty;

  /// Without Supabase config the app runs in demo mode on local fake data,
  /// like the Claude Design prototype.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
