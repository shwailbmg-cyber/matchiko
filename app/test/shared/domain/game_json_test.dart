import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/team.dart';

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

  test('Pitch.fromJson reads list_pitches()', () {
    final p = Pitch.fromJson(_fixture('pitch_json'));
    expect(p.priceDa, greaterThan(0));
    expect(p.maxPerSide, inInclusiveRange(3, 11));
  });

  test('Player.fromJson reads get_player()', () {
    final p = Player.fromJson(_fixture('player_json'));
    expect(p.handle, 'manager_harrach');
    expect(p.friend, FriendStatus.none);
    expect(p.wilayaId, 'alger');
  });

  test('Team.fromJson reads my_teams()', () {
    final t = Team.fromJson(_fixture('team_json'));
    expect(t.name, 'Harrach Lions');
    expect(t.iAmCaptain, isTrue);
    expect(t.members.single.positions, [Position.mid, Position.fwd]);
    expect(t.hasUsualGame, isFalse);
  });
}

Map<String, dynamic> _fixture(String name) =>
    jsonDecode(File('test/fixtures/$name.json').readAsStringSync())
        as Map<String, dynamic>;
