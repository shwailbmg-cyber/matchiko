import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/profile.dart';

import '../../helpers.dart';

void main() {
  testWidgets('a new player completes the 3 onboarding steps', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository(onboarded: false);
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();

    await t.tap(find.text('Player'));
    await t.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);

    // Step 1: name is prefilled; the wilaya is required.
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();
    expect(find.text('Step 1 of 3'), findsOneWidget);
    await t.tap(find.text('Choose your wilaya'));
    await t.pumpAndSettle();
    await t.enterText(find.byType(TextField).last, '68');
    await t.pumpAndSettle();
    await t.tap(find.text('68 · Bou Saâda'));
    await t.pumpAndSettle();
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();

    // Step 2: level.
    expect(find.text('Step 2 of 3'), findsOneWidget);
    await t.tap(find.text('Good'));
    await t.tap(find.text('Next'));
    await t.pumpAndSettle();

    // Step 3: phone must be an Algerian mobile.
    await t.enterText(find.byType(TextField), '0212 34 56 78');
    await t.tap(find.text("Let's play"));
    await t.pumpAndSettle();
    expect(
      find.text('Enter an Algerian mobile number (05, 06 or 07).'),
      findsOneWidget,
    );
    await t.enterText(find.byType(TextField), '0661 00 00 00');
    await t.tap(find.text("Let's play"));
    await t.pumpAndSettle();

    expect(find.text('Ready to play tonight?'.toUpperCase()), findsOneWidget);
    final me = await games.me();
    expect(me.onboarded, isTrue);
    expect(me.wilayaId, 'bou_saada');
    expect(me.level, Level.good);
    expect(me.phone, '+213661000000');
  });
}
