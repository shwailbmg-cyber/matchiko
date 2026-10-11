import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/player.dart';

part 'team.freezed.dart';

/// A team: captain, members, size and its usual weekly game.
@freezed
abstract class Team with _$Team {
  const Team._();

  const factory Team({
    required String id,
    required String name,
    required int perSide,
    required String captainHandle,
    @Default(<Player>[]) List<Player> members,
    @Default(false) bool iAmCaptain,

    /// ISO weekday, 1 = Monday.
    int? usualWeekday,
    int? usualHour,
    String? usualPitchId,
    @Default(0) int wins,
    @Default(0) int draws,
    @Default(0) int losses,
  }) = _Team;

  bool get hasUsualGame => usualWeekday != null && usualHour != null;

  /// "12-3-4" (wins-draws-losses).
  String get record => '$wins-$draws-$losses';
}
