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

  Future<void> load() async {
    final code = await _repo.loadLanguage();
    if (code != null) {
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
