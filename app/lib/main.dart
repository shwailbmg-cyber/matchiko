import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_demo.dart';
import 'data/repositories/auth_repository_supabase.dart';
import 'data/repositories/game_repository.dart';
import 'data/repositories/game_repository_demo.dart';
import 'data/repositories/settings_repository.dart';
import 'ui/features/auth/view_models/session_view_model.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final AuthRepository auth;
  if (Env.hasSupabase) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      publishableKey: Env.supabasePublishableKey,
    );
    auth = SupabaseAuthRepository(Supabase.instance.client);
  } else {
    auth = DemoAuthRepository();
  }

  // Games run on sample data in both modes until the Supabase repository
  // lands (M2). The database already enforces the rules either way.
  final GameRepository games = DemoGameRepository(
    latency: const Duration(milliseconds: 300),
  );

  final settings = SettingsViewModel(
    SettingsRepository(SharedPreferencesAsync()),
  );
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        ChangeNotifierProvider<GameRepository>.value(value: games),
        ChangeNotifierProvider(create: (_) => SessionViewModel(auth)),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: const MatchikoApp(),
    ),
  );
}
