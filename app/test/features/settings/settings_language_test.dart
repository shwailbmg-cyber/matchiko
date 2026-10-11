import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/core/settings/locale_controller.dart';

import '../../helpers.dart';

void main() {
  test('follows the phone language when supported', () {
    expect(pickLanguage(device: 'ar'), 'ar');
  });

  test('falls back to English otherwise', () {
    expect(pickLanguage(device: 'de'), 'en');
  });

  test('a saved choice wins over the phone language', () {
    expect(pickLanguage(saved: 'fr', device: 'ar'), 'fr');
  });

  test('changing the language saves it on the device', () async {
    final settings = memorySettings();
    final c = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        savedLanguageProvider.overrideWithValue('en'),
      ],
    );
    addTearDown(c.dispose);
    await c.read(localeProvider.notifier).setLanguage('fr');
    expect(c.read(localeProvider).languageCode, 'fr');
    expect(await settings.loadLanguage(), 'fr');
  });
}
