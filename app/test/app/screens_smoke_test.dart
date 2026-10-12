import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/features/auth/data/auth_repository_demo.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/widgets/mk_nav_bar.dart';

import '../helpers.dart';

/// Opens every screen on a phone-sized view in each language. Any overflow
/// or layout error fails the test.
void main() {
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

      final auth = DemoAuthRepository();
      await t.pumpWidget(testApp(auth: auth, language: lang));
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
      await open(t, Routes.editProfile);
      await open(t, Routes.privacy);
      await open(t, Routes.pitches);
      await open(t, Routes.wallet);
      await open(t, Routes.friends);
      await open(t, Routes.teams);
      await open(t, Routes.team('t1'));
      await open(t, Routes.referee);
      await open(t, Routes.matchReport('r1'));
      await open(t, Routes.player('samy_lounis', game: 'g1'));

      await auth.signOut();
      await t.pumpAndSettle();

      await t.tap(find.text(l.roleManager));
      await t.pumpAndSettle();
      for (var i = 1; i < 4; i++) {
        await tab(t, i);
      }
      await open(t, Routes.mVenue);
      await open(t, Routes.mReports);
      expect(t.takeException(), isNull);
    });
  }
}
