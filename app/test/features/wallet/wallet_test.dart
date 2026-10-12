import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/ledger_entry.dart';

import '../../helpers.dart';

void main() {
  test('ledger rows parse from the database shape', () {
    final e = LedgerEntry.fromJson({
      'reason': 'no_show',
      'xp_delta': -50,
      'coins_delta': -30,
      'created_at': '2026-10-01T20:00:00Z',
    });
    expect(e.reason, RewardReason.noShow);
    expect(e.coinsDelta, -30);
  });

  testWidgets('wallet shows balances and the cancellation penalty', (t) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = DemoGameRepository();
    await games.cancelBooking('g1');
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();

    await t.tap(find.text('Profile'));
    await t.pumpAndSettle();
    await t.tap(find.text('Coins').first);
    await t.pumpAndSettle();

    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Cancelled a booking'), findsOneWidget);
    expect(find.text('-10 🪙'), findsOneWidget);
  });
}
