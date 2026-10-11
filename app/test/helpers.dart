import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/app.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/core/settings/settings_repository.dart';
import 'package:matchiko/features/auth/data/auth_repository_demo.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Fresh in-memory preferences for each test.
SettingsRepository memorySettings() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
  return SettingsRepository(SharedPreferencesAsync());
}

/// The whole app on demo data, like `main()` without a backend.
Widget testApp({
  AuthRepository? auth,
  GameRepository? games,
  String language = 'en',
}) => ProviderScope(
  overrides: [
    authRepositoryProvider.overrideWithValue(auth ?? DemoAuthRepository()),
    gameRepositoryProvider.overrideWithValue(games ?? DemoGameRepository()),
    settingsRepositoryProvider.overrideWithValue(memorySettings()),
    savedLanguageProvider.overrideWithValue(language),
  ],
  child: const MatchikoApp(),
);
