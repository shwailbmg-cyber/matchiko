import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/my_settings.dart';

import '../../helpers.dart';

void main() {
  Future<DemoGameRepository> openSettings(WidgetTester t) async {
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
    await t.tap(find.byTooltip('Settings'));
    await t.pumpAndSettle();
    return games;
  }

  testWidgets('privacy, report a problem, delete account guard', (t) async {
    final games = await openSettings(t);

    await scrollTo(t, find.text('Nobody'));
    await t.tap(find.text('Nobody'));
    await t.pumpAndSettle();
    expect((await games.mySettings()).visibility, GamesVisibility.nobody);

    await scrollTo(t, find.text('Report a problem'));
    await t.tap(find.text('Report a problem'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'The map does not load.');
    await t.pumpAndSettle();
    await t.tap(find.text('Send'));
    await t.pumpAndSettle();
    expect(games.supportMessages, ['The map does not load.']);
    await t.pump(const Duration(seconds: 5)); // let the snackbar go
    await t.pumpAndSettle();

    // The demo player books tonight's game: deleting is refused for now.
    await scrollTo(t, find.text('Delete my account'));
    await t.tap(find.text('Delete my account'));
    await t.pumpAndSettle();
    await t.tap(find.text('Delete for good'));
    await t.pumpAndSettle();
    expect(games.deleted, isFalse);
    expect(
      find.textContaining('Cancel your upcoming bookings'),
      findsOneWidget,
    );
  });

  testWidgets('block a player, then unblock from settings', (t) async {
    final games = await openSettings(t);
    await games.block('anis_rahmani');
    await t.pumpAndSettle();

    await scrollTo(t, find.text('Blocked players'));
    await t.tap(find.text('Blocked players'));
    await t.pumpAndSettle();
    expect(find.text('Anis Rahmani'), findsOneWidget);
    await t.tap(find.text('Unblock'));
    await t.pumpAndSettle();
    expect(find.text('You have not blocked anyone.'), findsOneWidget);
    expect(await games.blockedPlayers(), isEmpty);
    expect(Routes.privacy, '/privacy');
  });
}
