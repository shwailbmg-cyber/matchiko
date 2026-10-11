import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';

import '../../helpers.dart';

void main() {
  testWidgets('filter the pitch list and toggle a favourite', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();

    await t.scrollUntilVisible(
      find.text('See all'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await t.drag(find.byType(Scrollable).first, const Offset(0, -200));
    await t.pumpAndSettle();
    await t.tap(find.text('See all'));
    await t.pumpAndSettle();
    expect(find.text('All pitches'), findsOneWidget);
    expect(find.text('Complexe El Harrach'), findsOneWidget);

    // 11v11 only fits the Biar stadium.
    await t.ensureVisible(find.text('11v11+'));
    await t.tap(find.text('11v11+'));
    await t.pumpAndSettle();
    expect(find.text('Complexe El Harrach'), findsNothing);
    await t.tap(find.text('11v11+'));
    await t.pumpAndSettle();

    // Harrach starts as a favourite; remove it, then favourites is empty.
    await t.ensureVisible(find.textContaining('Favourites'));
    await t.pumpAndSettle();
    await t.tap(find.textContaining('Favourites'));
    await t.pumpAndSettle();
    expect(find.text('Complexe El Harrach'), findsOneWidget);
    await t.tap(find.byTooltip('Remove from favourites'));
    await t.pumpAndSettle();
    expect(find.text('No pitch matches these filters.'), findsOneWidget);
    expect(await games.favoritePitchIds(), isEmpty);

    await t.tap(find.text('Clear filters'));
    await t.pumpAndSettle();
    expect(find.text('Complexe El Harrach'), findsOneWidget);
  });
}
