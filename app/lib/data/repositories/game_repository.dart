import 'package:flutter/foundation.dart';

import '../../domain/models/game.dart';
import '../../domain/models/pitch.dart';
import '../../domain/models/position.dart';
import '../../domain/models/profile.dart';

/// Everything the screens read and do about pitches, games and the signed-in
/// player. Notifies listeners when data changes (Realtime later), so view
/// models just reload.
///
/// Two implementations: [DemoGameRepository] (sample data, no server) and,
/// later, a Supabase one calling the RPCs in `supabase/migrations`. Rules
/// (prices, statuses, rewards) are enforced by the server, never here.
abstract class GameRepository extends ChangeNotifier {
  Future<Profile> me();
  Future<List<Pitch>> pitches({String query = ''});
  Future<Pitch> pitch(String id);
  Future<List<Slot>> slots(String pitchId, DateTime day);

  /// Open games near me that still need players.
  Future<List<Game>> openGames();
  Future<List<Game>> myUpcoming();
  Future<List<Game>> myPast();
  Future<Game> game(String id);

  /// Players searching near me right now (home counter).
  Future<int> liveSearching();

  /// Returns the new game's id. Throws [NotVerifiedException] when the
  /// player isn't verified yet.
  Future<String> requestBooking({
    required String pitchId,
    required DateTime startsAt,
    required int perSide,
    bool withReferee = false,
  });
  Future<void> joinGame(String gameId, Position position);
  Future<void> confirmComing(String gameId, {required bool coming});
  Future<void> cancelBooking(String gameId);
  Future<void> setOpen(String gameId, {required bool open});
  Future<void> setPaid(String gameId, String handle, {required bool paid});
  Future<void> setGameSize(String gameId, int perSide);

  /// Simple matchmaking: best open game for these positions, or null.
  Future<Game?> findGame({required List<Position> positions});

  // ── Manager ──────────────────────────────────────────────────────────
  Future<List<Game>> venueToday();
  Future<void> confirmBooking(String gameId);

  /// Returns the booking the QR code belongs to, now Guaranteed.
  Future<Game> scanBooking(String code);
  Future<void> markNoShow(String gameId);
  Future<List<Profile>> verificationQueue();
  Future<void> verifyPlayer(String handle);
}

class NotVerifiedException implements Exception {
  const NotVerifiedException();
}
