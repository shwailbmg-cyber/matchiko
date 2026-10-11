import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/app_notification.dart';

import '../../helpers.dart';

void main() {
  test('unknown kinds from a newer server do not break the list', () {
    final n = AppNotification.fromJson({
      'id': 9,
      'kind': 'tournament_invite',
      'payload': {'x': 1},
      'created_at': '2026-10-01T20:00:00Z',
    });
    expect(n.kind, NotificationKind.other);
    expect(n.unread, isTrue);
  });

  testWidgets('bell badge, list, then read after leaving', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();
    expect(find.text('3'), findsOneWidget); // unread badge

    await t.tap(find.byTooltip('Notifications'));
    await t.pumpAndSettle();
    expect(find.text('New friend request'), findsOneWidget);
    expect(find.text('Farid Ouali wants to add you.'), findsOneWidget);
    expect(find.text('Please confirm your game at 21:00.'), findsOneWidget);

    await t.pageBack();
    await t.pumpAndSettle();
    expect(find.text('3'), findsNothing);
    final list = await games.notifications();
    expect(list.where((n) => n.unread), isEmpty);
  });
}
