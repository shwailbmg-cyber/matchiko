import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/data/repositories/settings_repository.dart';
import 'package:matchiko/ui/features/settings/view_models/settings_view_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  SettingsViewModel vm() =>
      SettingsViewModel(SettingsRepository(SharedPreferencesAsync()));

  test('follows the phone language when supported', () async {
    final s = vm();
    await s.load(deviceLanguage: 'ar');
    expect(s.locale.languageCode, 'ar');
  });

  test('falls back to English otherwise', () async {
    final s = vm();
    await s.load(deviceLanguage: 'de');
    expect(s.locale.languageCode, 'en');
  });

  test('a saved choice wins over the phone language', () async {
    await vm().setLanguage('fr');
    final s = vm();
    await s.load(deviceLanguage: 'ar');
    expect(s.locale.languageCode, 'fr');
  });
}
