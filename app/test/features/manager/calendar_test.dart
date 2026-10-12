import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/calendar_entry.dart';

import '../../helpers.dart';

void main() {
  testWidgets('manager adds and frees a walk-in booking', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Stadium manager'));
    await t.pumpAndSettle();
    await t.tap(find.text('Calendar'));
    await t.pumpAndSettle();

    // Tomorrow: the demo has maintenance at 18:00.
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    await t.tap(find.text('${tomorrow.day}').first);
    await t.pumpAndSettle();
    await scrollTo(t, find.text('🔒 Maintenance'));
    expect(find.text('🔒 Maintenance'), findsOneWidget);

    // 10:00 tomorrow is free in the demo calendar.
    await scrollTo(t, find.text('10:00'));
    await t.tap(find.text('Free').first);
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).first, 'Yacine');
    await t.enterText(find.byType(TextField).last, '0661 00 00 00');
    await t.pumpAndSettle();
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('🚶 Yacine'), findsOneWidget);

    final from = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    final week = await games.venueWeek('harrach', from);
    final walkIn = week.firstWhere((e) => e.label == 'Yacine');
    expect(walkIn.kind, CalendarKind.walkIn);
    expect(walkIn.phone, '+213661000000');

    await t.tap(find.text('🚶 Yacine'));
    await t.pumpAndSettle();
    await t.tap(find.text('Free this hour'));
    await t.pumpAndSettle();
    expect(find.text('🚶 Yacine'), findsNothing);
  });
}
