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

  /// Without Supabase config the app runs in demo mode on local fake data,
  /// like the Claude Design prototype.
  static bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
