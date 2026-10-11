import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/booking_status.dart';

part 'calendar_entry.freezed.dart';

enum CalendarKind { booking, blocked, walkIn }

/// One taken hour in the manager's calendar: an app booking, a blocked
/// slot or a walk-in typed in by the manager (`pitch_blocks`).
@freezed
abstract class CalendarEntry with _$CalendarEntry {
  const factory CalendarEntry({
    required String id,
    required DateTime startsAt,
    required CalendarKind kind,

    /// Booker name, block reason or walk-in customer name.
    @Default('') String label,
    String? phone,
    BookingStatus? status,
    String? gameId,
  }) = _CalendarEntry;
}
