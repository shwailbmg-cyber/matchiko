import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/app.dart';
import 'package:matchiko/core/env.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/core/settings/settings_repository.dart';
import 'package:matchiko/features/auth/data/auth_repository_demo.dart';
import 'package:matchiko/features/auth/data/auth_repository_supabase.dart';
import 'package:matchiko/features/auth/data/secure_session_storage.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository auth;
  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
      authOptions: const FlutterAuthClientOptions(
        localStorage: SecureSessionStorage(),
      ),
    );
    auth = SupabaseAuthRepository(Supabase.instance.client);
  } else {
    auth = DemoAuthRepository();
  }

  final settings = SettingsRepository(SharedPreferencesAsync());
  final savedLanguage = await settings.loadLanguage();

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(auth),
        // Games run on sample data in both modes until the Supabase
        // repository lands (LOOP.md S18). The database enforces the rules.
        gameRepositoryProvider.overrideWithValue(
          DemoGameRepository(
            latency: const Duration(milliseconds: 300),
            onboarded: false,
          ),
        ),
        settingsRepositoryProvider.overrideWithValue(settings),
        savedLanguageProvider.overrideWithValue(savedLanguage),
      ],
      child: const MatchikoApp(),
    ),
  );
}
