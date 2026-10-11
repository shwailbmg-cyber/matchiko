import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/ledger_entry.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';

/// Everything the screens read and do about pitches, games and the signed-in
/// player. [changes] ticks when data changes (Realtime later), so the
/// providers that read it refetch.
///
/// Two implementations: [DemoGameRepository] (sample data, no server) and,
/// later, a Supabase one calling the RPCs in `supabase/migrations`. Rules
/// (prices, statuses, rewards) are enforced by the server, never here.
abstract interface class GameRepository {
  /// Emits a new number every time any data changes.
  Stream<int> get changes;

  Future<Profile> me();

  /// Onboarding and "Edit profile". The server checks every field again
  /// (handle, phone format, positions 1–4, level values).
  Future<void> updateProfile({
    required String name,
    required String wilayaId,
    required List<Position> positions,
    required Level level,
    required String phone,
  });
  Future<List<Pitch>> pitches({String query = ''});
  Future<Pitch> pitch(String id);
  Future<List<Slot>> slots(String pitchId, DateTime day);

  // ── Players and friends ──────────────────────────────────────────────
  /// Players by name or @handle (public profile columns only).
  Future<List<Player>> searchPlayers(String query);
  Future<Player> player(String handle);

  /// Friends, requests I received and requests I sent.
  Future<List<Player>> friends();
  Future<void> addFriend(String handle);
  Future<void> acceptFriend(String handle);

  /// Cancels a request, declines one, or removes a friend.
  Future<void> removeFriend(String handle);

  /// About a game both of us played, or about behaviour in general.
  /// A no-show report needs [gameId]. Checked by RLS on `player_reports`.
  Future<void> reportPlayer(
    String handle, {
    String? gameId,
    required ReportReason reason,
    String note = '',
  });

  // ── Notifications ────────────────────────────────────────────────────
  /// Newest first.
  Future<List<AppNotification>> notifications();
  Future<void> markNotificationsRead();

  /// My XP and coin changes, newest first.
  Future<List<LedgerEntry>> walletHistory();

  /// Ids of the pitches I marked with a heart (`favorite_pitches`).
  Future<Set<String>> favoritePitchIds();
  Future<void> setFavorite(String pitchId, {required bool favorite});

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
