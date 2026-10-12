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
  /// Firebase console (one Android app and one iOS app in the same
  /// project); empty → no push on that platform. See docs/PUSH.md.
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
  );
  static const firebaseAndroidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const firebaseAndroidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const firebaseIosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const firebaseIosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');

  /// Public URL of a profile photo path from the server (`<id>/avatar.jpg?v=…`).
  static String? avatarUrl(String? path) =>
      path == null || path.isEmpty || !hasSupabase
      ? null
      : '$supabaseUrl/storage/v1/object/public/avatars/$path';

  /// Without Supabase config the app runs in demo mode on local fake data,
  /// like the Claude Design prototype.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
