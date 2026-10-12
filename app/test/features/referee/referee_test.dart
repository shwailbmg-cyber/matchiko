import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';

import '../../helpers.dart';

void main() {
  Future<DemoGameRepository> openReferee(WidgetTester t) async {
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
    await scrollTo(t, find.text('Referee'));
    await t.tap(find.text('Referee'));
    await t.pumpAndSettle();
    return games;
  }

  testWidgets('take a job from the board', (t) async {
    final games = await openReferee(t);
    expect(find.text('GAMES LOOKING FOR A REFEREE'), findsOneWidget);
    await t.tap(find.text('Take').first);
    await t.pumpAndSettle();
    final mine = (await games.refereeJobs()).where((j) => j.mine);
    expect(mine.map((j) => j.bookingId), contains('j1'));
  });

  testWidgets('write a match report', (t) async {
    final games = await openReferee(t);
    final before = (await games.me()).coins;
    await t.tap(find.text('Open report'));
    await t.pumpAndSettle();

    await t.tap(find.text('Samy Lounis'));
    await t.pumpAndSettle();
    await t.tap(find.text('Goal'));
    await t.pumpAndSettle();
    expect(find.text('A   1 – 0   B'), findsOneWidget);

    await scrollTo(t, find.text('Submit report'));
    await t.tap(find.text('Submit report'));
    await t.pumpAndSettle();
    expect((await games.me()).coins, before + 50);
    expect(find.text('Open report'), findsNothing);
  });
}
