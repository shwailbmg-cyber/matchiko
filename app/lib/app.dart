import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'l10n/gen/app_localizations.dart';
import 'routing/router.dart';
import 'ui/core/theme/mk_theme.dart';
import 'ui/features/auth/view_models/session_view_model.dart';
import 'ui/features/settings/view_models/settings_view_model.dart';

class MatchikoApp extends StatefulWidget {
  const MatchikoApp({super.key});

  @override
  State<MatchikoApp> createState() => _MatchikoAppState();
}

class _MatchikoAppState extends State<MatchikoApp> {
  late final GoRouter _router = buildRouter(context.read<SessionViewModel>());
  final _theme = buildMkTheme();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.select((SettingsViewModel s) => s.locale);
    return MaterialApp.router(
      title: 'Matchiko',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      themeMode: ThemeMode.dark,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: _router,
    );
  }
}
