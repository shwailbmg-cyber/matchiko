import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';

import '../../helpers.dart';

void main() {
  testWidgets('reports show cash and occupancy; manage staff', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Stadium manager'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Reports'));
    await t.pumpAndSettle();

    expect(find.text('Cash expected'), findsOneWidget);
    expect(find.text('Occupancy'), findsOneWidget);
    final stats = await games.venueStats(
      DateTime.now().subtract(const Duration(days: 1)),
      DateTime.now().add(const Duration(days: 1)),
    );
    expect(stats.cashExpectedDa, greaterThanOrEqualTo(stats.cashReceivedDa));

    await scrollTo(t, find.text('Add'));
    await t.enterText(find.byType(TextField), '@samy_lounis');
    await t.tap(find.text('Add'));
    await t.pumpAndSettle();
    expect(find.text('Samy Lounis'), findsOneWidget);

    await t.enterText(find.byType(TextField), '@nobody_here');
    await t.tap(find.text('Add'));
    await t.pumpAndSettle();
    expect(find.text('No verified player with this @handle.'), findsOneWidget);
  });
}
