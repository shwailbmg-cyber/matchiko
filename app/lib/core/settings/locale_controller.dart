import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/settings/settings_repository.dart';

/// Device preferences. `main()` overrides it with real storage.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => throw UnimplementedError('Override settingsRepositoryProvider'),
);

/// Language saved on this device, read once before the app starts.
final savedLanguageProvider = Provider<String?>((ref) => null);

/// App language (EN / FR / AR). Arabic switches the whole app to RTL through
/// Flutter's localizations; widgets only need directional padding/alignment.
class LocaleController extends Notifier<Locale> {
  @override
  Locale build() => Locale(
    pickLanguage(
      saved: ref.watch(savedLanguageProvider),
      device: PlatformDispatcher.instance.locale.languageCode,
    ),
  );

  Future<void> setLanguage(String code) async {
    if (code == state.languageCode) return;
    state = Locale(code);
    await ref.read(settingsRepositoryProvider).saveLanguage(code);
  }
}

final localeProvider = NotifierProvider<LocaleController, Locale>(
  LocaleController.new,
);

/// Saved choice first, else the phone's language if we support it, else
/// English (younger players use English more than French).
String pickLanguage({String? saved, required String device}) =>
    saved ?? (SettingsRepository.supported.contains(device) ? device : 'en');
