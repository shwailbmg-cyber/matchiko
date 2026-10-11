import 'package:shared_preferences/shared_preferences.dart';

/// Non-sensitive device preferences. Never store tokens or PII here.
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferencesAsync _prefs;

  static const _langKey = 'lang';
  static const supported = ['en', 'fr', 'ar'];

  Future<String?> loadLanguage() async {
    final v = await _prefs.getString(_langKey);
    return supported.contains(v) ? v : null;
  }

  Future<void> saveLanguage(String code) => _prefs.setString(_langKey, code);
}
