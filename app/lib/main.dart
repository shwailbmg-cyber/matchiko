import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/app.dart';
import 'package:matchiko/core/env.dart';
import 'package:matchiko/core/errors.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/core/settings/settings_repository.dart';
import 'package:matchiko/features/auth/data/auth_repository_demo.dart';
import 'package:matchiko/features/auth/data/auth_repository_supabase.dart';
import 'package:matchiko/features/auth/data/secure_session_storage.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/data/game_repository_supabase.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // A failed action (no network, refused by the server) shows a snackbar
  // instead of failing silently.
  PlatformDispatcher.instance.onError = (error, stack) {
    showError(error);
    return true;
  };

  final AuthRepository auth;
  final GameRepository games;
  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
      ),
    );
    auth = SupabaseAuthRepository(Supabase.instance.client);
    games = SupabaseGameRepository(Supabase.instance.client);
  } else {
    auth = DemoAuthRepository();
    games = DemoGameRepository(
      latency: const Duration(milliseconds: 300),
      onboarded: false,
    );
  }

  final settings = SettingsRepository(SharedPreferencesAsync());
  final savedLanguage = await settings.loadLanguage();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        gameRepositoryProvider.overrideWithValue(games),
        settingsRepositoryProvider.overrideWithValue(settings),
        savedLanguageProvider.overrideWithValue(savedLanguage),
      ],
      child: const MatchikoApp(),
    ),
  );
}
