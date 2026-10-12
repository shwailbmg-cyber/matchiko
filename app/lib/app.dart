import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/errors.dart';
import 'package:matchiko/core/router/router.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';

final _theme = buildMkTheme();

class MatchikoApp extends ConsumerWidget {
  const MatchikoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Matchiko',
      debugShowCheckedModeBanner: false,
      theme: _theme,
      themeMode: ThemeMode.dark,
      locale: ref.watch(localeProvider),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      routerConfig: ref.watch(routerProvider),
      scaffoldMessengerKey: messengerKey,
    );
  }
}
