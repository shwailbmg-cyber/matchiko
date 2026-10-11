import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/cost_share.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';

part 'game.freezed.dart';
part 'game.g.dart';

/// Which side of the pitch a player is on in a game.
enum Side { a, b }

@freezed
abstract class GamePlayer with _$GamePlayer {
  const GamePlayer._();

  const factory GamePlayer({
    required String name,
    required String handle,
    required Position position,
    required Side team,
    @Default(100) int reliability,
    @Default(false) bool paid,
    @Default(true) bool confirmed,

    /// Added by the booker, has no account.
    @Default(false) bool guest,
    @Default(false) bool isMe,
    @Default(false) bool isBooker,
  }) = _GamePlayer;

  factory GamePlayer.fromJson(Map<String, dynamic> json) =>
      _$GamePlayerFromJson(json);

  String get initials => initialsOf(name);
}

/// A game = one booked hour on a pitch, with its players.
@freezed
abstract class Game with _$Game {
  const Game._();

  const factory Game({
    required String id,
    required Pitch pitch,
    required DateTime startsAt,
    required int perSide,
    required BookingStatus status,
    required List<GamePlayer> players,

    /// Free spots shown to other players.
    @Default(false) bool open,
    @Default(0) int waitlist,
    @Default(false) bool competitive,

    /// Booking code shown under the QR.
    @Default('') String code,
  }) = _Game;

  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  int get capacity => perSide * 2;
  int get spotsLeft => (capacity - players.length).clamp(0, capacity);
  bool get full => spotsLeft == 0;
  GamePlayer? get me => players.where((p) => p.isMe).firstOrNull;
  bool get iAmBooker => me?.isBooker ?? false;
  int get goalkeepers => players.where((p) => p.position == Position.gk).length;

  CostShare get share => CostShare.split(
    priceDa: pitch.priceDa,
    players: players.isEmpty ? capacity : players.length,
    goalkeepers: goalkeepers,
  );
}
