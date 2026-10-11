import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/rank.dart';

part 'player.freezed.dart';

/// My friendship with another player, from my side.
enum FriendStatus { none, sent, incoming, friends }

/// Another player as anyone signed in may see them: public profile columns
/// only (no phone, no coins), plus my friendship with them.
@freezed
abstract class Player with _$Player {
  const Player._();

  const factory Player({
    required String handle,
    required String name,
    String? wilayaId,
    @Default(<Position>[]) List<Position> positions,
    @Default(0) int xp,
    @Default(false) bool verified,
    @Default(0) int played,
    @Default(FriendStatus.none) FriendStatus friend,
  }) = _Player;

  Rank get rank => Rank.fromXp(xp);
  String get initials => initialsOf(name);
}
