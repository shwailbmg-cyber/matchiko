import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue_stats.freezed.dart';
part 'venue_stats.g.dart';

/// Numbers for a period at my venue (`venue_report`).
@freezed
abstract class VenueStats with _$VenueStats {
  const VenueStats._();

  const factory VenueStats({
    @Default(0) int bookings,
    @Default(0) int requested,
    @Default(0) int confirmed,
    @Default(0) int guaranteed,
    @Default(0) int completed,
    @Default(0) int cancelled,
    @Default(0) int noShows,
    @Default(0) int walkIns,
    @Default(0) int cashExpectedDa,
    @Default(0) int cashReceivedDa,
    @Default(0) int bookedHours,
    @Default(0) int openHours,
  }) = _VenueStats;

  factory VenueStats.fromJson(Map<String, dynamic> json) =>
      _$VenueStatsFromJson(json);

  /// Cash still to collect for confirmed bookings.
  int get cashMissingDa => cashExpectedDa - cashReceivedDa;

  /// Share of open hours that were booked, 0 to 1.
  double get occupancy =>
      openHours == 0 ? 0 : (bookedHours / openHours).clamp(0, 1).toDouble();
}

/// A manager of my venue (`venue_staff`).
@freezed
abstract class StaffMember with _$StaffMember {
  const factory StaffMember({
    required String handle,
    required String name,
    @Default(false) bool isMe,
  }) = _StaffMember;
}
