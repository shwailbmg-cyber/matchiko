import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/player.dart';

import '../../helpers.dart';

void main() {
  testWidgets('accept a request, find a player, add them', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();
    await t.tap(find.text('Profile'));
    await t.pumpAndSettle();
    await scrollTo(t, find.text('Friends'));
    await t.tap(find.text('Friends'));
    await t.pumpAndSettle();

    // Farid sent me a request.
    expect(find.text('FRIEND REQUESTS · 1'), findsOneWidget);
    await t.tap(find.byTooltip('Accept'));
    await t.pumpAndSettle();
    expect(find.text('FRIENDS · 4'), findsOneWidget);

    // Search by @handle and add Riad.
    await t.enterText(find.byType(TextField), '@riad');
    await t.pumpAndSettle();
    await t.tap(find.byTooltip('Add friend'));
    await t.pumpAndSettle();
    expect(find.byTooltip('Request sent'), findsOneWidget);
    expect((await games.player('riad_mansouri')).friend, FriendStatus.sent);

    // Open his public profile.
    await t.tap(find.text('Riad Mansouri'));
    await t.pumpAndSettle();
    expect(find.text('@riad_mansouri · Boumerdès'), findsOneWidget);
  });
}
