import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/app_notification.dart';

import '../../helpers.dart';

void main() {
  testWidgets('report a no-show from the game page', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();

    await t.tap(find.text('Matches'));
    await t.pumpAndSettle();
    await t.tap(find.text('Complexe El Harrach').first);
    await t.pumpAndSettle();
    await scrollTo(t, find.text('Walid Djebbar'));
    await t.tap(find.text('Walid Djebbar'));
    await t.pumpAndSettle();

    await t.tap(find.text('Report'));
    await t.pumpAndSettle();
    await t.tap(find.text('Did not come to the game'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Report'));
    await t.pumpAndSettle();

    expect(find.text('Report sent'), findsOneWidget);
    expect(games.reports, [('walid_djebbar', ReportReason.noShow)]);
  });
}
