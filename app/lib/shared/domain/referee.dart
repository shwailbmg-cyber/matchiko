import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/game.dart';

part 'referee.freezed.dart';

/// Where I am on the referee path.
enum RefereeStatus { none, pending, approved }

/// Fee the booker pays the referee in cash (`request_booking`).
const refereeFeeDa = 200;

/// A game that asked for a referee: open on the job board, or mine.
@freezed
abstract class RefJob with _$RefJob {
  const RefJob._();

  const factory RefJob({
    required String bookingId,
    required DateTime startsAt,
    required String venue,
    required int perSide,

    /// Set once the game exists (needed for the match report).
    String? gameId,
    @Default(false) bool mine,
    @Default(false) bool reported,
  }) = _RefJob;

  bool needsReport(DateTime now) => mine && !reported && startsAt.isBefore(now);
}

/// Hours I can referee on one weekday (ISO, 1 = Monday).
@freezed
abstract class RefAvailability with _$RefAvailability {
  const factory RefAvailability({
    required int weekday,
    required int startHour,
    required int endHour,
  }) = _RefAvailability;
}

enum MatchEventType { goal, yellow, red, mvp }

/// One line of the match report (`submit_match_report` events).
@freezed
abstract class MatchEvent with _$MatchEvent {
  const factory MatchEvent({
    required MatchEventType type,
    required Side side,
    required String handle,
  }) = _MatchEvent;
}
