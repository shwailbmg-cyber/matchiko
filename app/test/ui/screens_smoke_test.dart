import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/app.dart';
import 'package:matchiko/data/repositories/auth_repository.dart';
import 'package:matchiko/data/repositories/auth_repository_demo.dart';
import 'package:matchiko/data/repositories/game_repository.dart';
import 'package:matchiko/data/repositories/game_repository_demo.dart';
import 'package:matchiko/data/repositories/settings_repository.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/routing/routes.dart';
import 'package:matchiko/ui/core/widgets/mk_nav_bar.dart';
import 'package:matchiko/ui/features/auth/view_models/session_view_model.dart';
import 'package:matchiko/ui/features/settings/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Opens every screen on a phone-sized view in each language. Any overflow
/// or layout error fails the test.
void main() {
  late SettingsViewModel settings;

  Widget app() {
    final auth = DemoAuthRepository();
    settings = SettingsViewModel(SettingsRepository(SharedPreferencesAsync()));
    return MultiProvider(
      providers: [
        Provider<AuthRepository>.value(value: auth),
        ChangeNotifierProvider<GameRepository>(
          create: (_) => DemoGameRepository(),
        ),
        ChangeNotifierProvider(create: (_) => SessionViewModel(auth)),
        ChangeNotifierProvider.value(value: settings),
      ],
      child: const MatchikoApp(),
    );
  }

  // Real fonts, so text widths match a phone (the default test font draws
  // every glyph as a full square).
  setUpAll(() async {
    Future<void> load(String family, List<String> files) async {
      final loader = FontLoader(family);
      for (final f in files) {
        final bytes = File('assets/fonts/$f').readAsBytesSync();
        loader.addFont(Future.value(ByteData.sublistView(bytes)));
      }
      await loader.load();
    }

    await load('BarlowCondensed', [
      'BarlowCondensed-SemiBold.ttf',
      'BarlowCondensed-Bold.ttf',
      'BarlowCondensed-ExtraBold.ttf',
    ]);
    await load('Cairo', ['Cairo-Variable.ttf']);
  });

  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  Future<void> tab(WidgetTester t, int i) async {
    final items = find.descendant(
      of: find.byType(MkNavBar),
      matching: find.byType(InkResponse),
    );
    await t.tap(items.at(i));
    await t.pumpAndSettle();
  }

  Future<void> open(WidgetTester t, String path) async {
    final ctx = t.element(find.byType(Scaffold).first);
    unawaited(GoRouter.of(ctx).push(path));
    await t.pumpAndSettle();
    GoRouter.of(t.element(find.byType(Scaffold).last)).pop();
    await t.pumpAndSettle();
  }

  for (final lang in ['en', 'fr', 'ar']) {
    testWidgets('every screen lays out in $lang', (t) async {
      t.view.physicalSize = const Size(360 * 3, 740 * 3);
      t.view.devicePixelRatio = 3;
      addTearDown(t.view.reset);

      await t.pumpWidget(app());
      await t.pumpAndSettle();
      await settings.setLanguage(lang);
      await t.pumpAndSettle();
      final l = lookupAppLocalizations(Locale(lang));

      await t.tap(find.text(l.rolePlayer));
      await t.pumpAndSettle();
      for (var i = 1; i < 4; i++) {
        await tab(t, i);
      }
      await tab(t, 0);
      await open(t, Routes.game('g1'));
      await open(t, Routes.game('o1'));
      await open(t, Routes.pitch('harrach'));
      await open(t, Routes.notifications);
      await open(t, Routes.settings);

      final ctx = t.element(find.byType(Scaffold).first);
      await ctx.read<SessionViewModel>().signOut();
      await t.pumpAndSettle();

      await t.tap(find.text(l.roleManager));
      await t.pumpAndSettle();
      for (var i = 1; i < 4; i++) {
        await tab(t, i);
      }
      expect(t.takeException(), isNull);
    });
  }
}
