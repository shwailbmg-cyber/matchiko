import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../../../../data/repositories/settings_repository.dart';

/// App language (EN / FR / AR). Arabic switches the whole app to RTL through
/// Flutter's localizations, no extra work needed in widgets that use
/// `EdgeInsetsDirectional` / `AlignmentDirectional`.
class SettingsViewModel extends ChangeNotifier {
  SettingsViewModel(this._repo);

  final SettingsRepository _repo;

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  /// Saved choice first, else the phone's language if we support it,
  /// else English (younger players use English more than French).
  Future<void> load({String? deviceLanguage}) async {
    final device =
        deviceLanguage ?? PlatformDispatcher.instance.locale.languageCode;
    final code =
        await _repo.loadLanguage() ??
        (SettingsRepository.supported.contains(device) ? device : 'en');
    if (code != _locale.languageCode) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLanguage(String code) async {
    if (code == _locale.languageCode) return;
    _locale = Locale(code);
    notifyListeners();
    await _repo.saveLanguage(code);
  }
}
