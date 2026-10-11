import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';

import '../../helpers.dart';

void main() {
  testWidgets('manager changes a price and hides a pitch', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Stadium manager'));
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('My venue'));
    await t.pumpAndSettle();
    expect(find.text('OPENING HOURS'), findsOneWidget);

    await t.tap(find.text('Complexe El Harrach').last);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), '3000');
    await t.tap(find.text('Players can book this pitch'));
    await t.pumpAndSettle();
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();

    expect(find.text('${money(3000)} DA/h'), findsOneWidget);
    expect(find.textContaining('Hidden from players'), findsOneWidget);
    final visible = await games.pitches();
    expect(visible.map((p) => p.id), isNot(contains('harrach')));
  });
}
