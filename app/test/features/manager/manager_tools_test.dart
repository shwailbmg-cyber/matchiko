import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/game.dart';

import '../../helpers.dart';

void main() {
  Future<DemoGameRepository> asManager(WidgetTester t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Stadium manager'));
    await t.pumpAndSettle();
    return games;
  }

  testWidgets('verify a player and check players in from the scanner', (
    t,
  ) async {
    final games = await asManager(t);
    await t.tap(find.text('Scan'));
    await t.pumpAndSettle();

    await t.tap(find.text('ID check'));
    await t.pumpAndSettle();
    final before = (await games.verificationQueue()).length;
    await t.tap(find.text('Simulate scan'));
    await t.pumpAndSettle();
    for (final label in ['Name matches ID card', 'Photo matches face']) {
      await t.tap(find.text(label));
    }
    await t.tap(find.textContaining('15'));
    await t.pumpAndSettle();
    await scrollTo(t, find.textContaining('Verify'));
    await t.tap(find.textContaining('Verify'));
    await t.pumpAndSettle();
    expect((await games.verificationQueue()).length, before - 1);

    await t.tap(find.text('Arrival'));
    await t.pumpAndSettle();
    int arrived(List<Game> gs) =>
        gs.expand((g) => g.players).where((p) => p.attended).length;
    final was = arrived(await games.venueToday());
    await scrollTo(t, find.text('Simulate scan'));
    await t.tap(find.text('Simulate scan'));
    await t.pumpAndSettle();
    expect(arrived(await games.venueToday()), was + 1);
    expect(find.textContaining('arrived'), findsWidgets);
  });

  testWidgets('approve a referee and confirm a no-show report', (t) async {
    final games = await asManager(t);
    await t.tap(find.text('Players'));
    await t.pumpAndSettle();

    await scrollTo(t, find.byTooltip('Approve'));
    await t.tap(find.byTooltip('Approve'));
    await t.pumpAndSettle();
    expect(await games.refereeApplications(), isEmpty);

    await scrollTo(t, find.text('Confirm'));
    await t.tap(find.text('Confirm'));
    await t.pumpAndSettle();
    expect(await games.venueReports(), isEmpty);
  });
}
