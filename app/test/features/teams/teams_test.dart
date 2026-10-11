import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';

import '../../helpers.dart';

void main() {
  Future<void> openTeams(WidgetTester t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();
    await t.tap(find.text('Profile'));
    await t.pumpAndSettle();
    await scrollTo(t, find.text('My teams'));
    await t.tap(find.text('My teams'));
    await t.pumpAndSettle();
  }

  testWidgets('create a team and add a friend', (t) async {
    final games = DemoGameRepository();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await openTeams(t);
    expect(find.text('Harrach Lions'), findsOneWidget);

    await t.tap(find.text('Create a team'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField), 'Bab Ezzouar FC');
    await t.tap(find.text('5v5'));
    await t.pumpAndSettle();
    await t.tap(find.widgetWithText(FilledButton, 'Create a team'));
    await t.pumpAndSettle();

    expect(find.text('Bab Ezzouar FC'), findsOneWidget);
    expect(find.text('No usual game yet'), findsOneWidget);
    await t.tap(find.text('Add a friend to the team'));
    await t.pumpAndSettle();
    await t.tap(find.text('Samy Lounis'));
    await t.pumpAndSettle();
    expect(find.text('Samy Lounis'), findsOneWidget);
    final teams = await games.myTeams();
    expect(teams.last.members.map((m) => m.handle), contains('samy_lounis'));
  });

  testWidgets('captain changes the usual game', (t) async {
    await t.pumpWidget(testApp());
    await t.pumpAndSettle();
    await openTeams(t);
    await t.tap(find.text('Harrach Lions'));
    await t.pumpAndSettle();
    expect(find.text('Every Tuesday at 21:00'), findsOneWidget);

    await t.tap(find.text('Set the usual game'));
    await t.pumpAndSettle();
    await t.tap(find.text('Friday'));
    await t.tap(find.text('20:00'));
    await t.tap(find.text('Save'));
    await t.pumpAndSettle();
    expect(find.text('Every Friday at 20:00'), findsOneWidget);
    expect(Routes.team('t1'), '/team/t1');
  });
}
