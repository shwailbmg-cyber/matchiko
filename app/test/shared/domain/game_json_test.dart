import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/position.dart';

/// The fixture is real `public.game_json()` output (dumped from Postgres),
/// so this test breaks if the SQL and the Dart model drift apart.
void main() {
  test('Game.fromJson reads the server game JSON', () {
    final json = jsonDecode(
      File('test/fixtures/game_json.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final g = Game.fromJson(json);
    expect(g.status, BookingStatus.requested);
    expect(g.perSide, 7);
    expect(g.pitch.venue, 'Complexe El Harrach');
    expect(g.pitch.features, containsAll([Feature.light, Feature.roof]));
    expect(g.players.single.isBooker, isTrue);
    expect(g.players.single.team, Side.a);
    expect(g.players.single.position, Position.mid);
    expect(g.iAmBooker, isTrue);
    expect(g.code, isNotEmpty);
  });
}
