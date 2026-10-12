import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/core/errors.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/game.dart';

import '../helpers.dart';

/// Demo data, but the network is down for the home screen and nothing is
/// booked yet.
class _Offline extends DemoGameRepository {
  bool down = true;

  @override
  Future<List<Game>> openGames() async {
    if (down) throw const SocketException('Failed host lookup');
    return super.openGames();
  }

  @override
  Future<List<Game>> myUpcoming() async => [];
}

void main() {
  test('network errors read as offline', () {
    expect(isOffline(const SocketException('x')), isTrue);
    expect(isOffline(Exception('Failed host lookup: api')), isTrue);
    expect(isOffline(StateError('slot already booked')), isFalse);
  });

  testWidgets('offline screen with retry, empty matches with a way out', (
    t,
  ) async {
    t.view.physicalSize = const Size(390 * 3, 844 * 3);
    t.view.devicePixelRatio = 3;
    addTearDown(t.view.reset);
    final games = _Offline();
    await t.pumpWidget(testApp(games: games));
    await t.pumpAndSettle();
    await t.tap(find.text('Player'));
    await t.pumpAndSettle();

    expect(
      find.text('No internet connection. Check your network and try again.'),
      findsOneWidget,
    );
    games.down = false;
    await t.tap(find.text('Try again'));
    await t.pumpAndSettle();
    expect(find.text('Ready to play tonight?'.toUpperCase()), findsOneWidget);

    await t.tap(find.text('Matches'));
    await t.pumpAndSettle();
    expect(find.text('No game booked yet'), findsOneWidget);
    await t.tap(find.text('Find me a game'));
    await t.pumpAndSettle();
    expect(find.text('Find my game'), findsOneWidget);
  });
}
