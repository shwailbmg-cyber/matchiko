import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/auth_repository_demo.dart';
import 'data/repositories/auth_repository_supabase.dart';
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

  final settings = SettingsViewModel(
    SettingsRepository(SharedPreferencesAsync()),
  );
  await settings.load();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        ChangeNotifierProvider(create: (_) => SessionViewModel(auth)),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: const MatchikoApp(),
    ),
  );
}
