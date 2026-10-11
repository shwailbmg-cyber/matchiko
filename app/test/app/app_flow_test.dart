import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers.dart';

void main() {
  testWidgets('demo login routes each role to its own area', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();
    expect(find.text('Continue as'.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Player'));
    await tester.pumpAndSettle();
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('Ready to play tonight?'.toUpperCase()), findsOneWidget);

    await tester.tap(find.text('Matches'));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming'), findsOneWidget);

    // Log out from settings, then come back as a manager.
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stadium manager'));
    await tester.pumpAndSettle();
    expect(find.text('To confirm'), findsOneWidget);
    expect(find.text('Play'), findsNothing);
  });

  testWidgets('Arabic switches the app to right-to-left', (tester) async {
    await tester.pumpWidget(testApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('ع'));
    await tester.pumpAndSettle();

    final ctx = tester.element(find.byType(Scaffold).first);
    expect(Directionality.of(ctx), TextDirection.rtl);
    expect(find.text('لاعب'), findsOneWidget);
  });
}
