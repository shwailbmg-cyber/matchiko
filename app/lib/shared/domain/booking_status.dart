import 'package:json_annotation/json_annotation.dart';

/// Booking lifecycle. The database enforces the same transitions in
/// `public.booking_status` + `bookings_status_guard`; this copy is only for
/// showing the right buttons in the UI. Never trust it for authorization.
enum BookingStatus {
  /// Sent by the player, waiting for the manager's call.
  requested,

  /// Manager took the call.
  confirmed,

  /// Full amount paid: cash scanned by QR, or online via SATIM.
  guaranteed,

  /// Game played.
  completed,
  cancelled,
  @JsonValue('no_show')
  noShow;

  static const _next = {
    requested: {confirmed, guaranteed, cancelled},
    confirmed: {guaranteed, cancelled, noShow},
    guaranteed: {completed, noShow},
  };

  bool canMoveTo(BookingStatus to) => _next[this]?.contains(to) ?? false;

  bool get isFinal => !_next.containsKey(this);

  /// Position on the 3-step ladder shown to players (-1 when off the ladder).
  int get ladderStep => switch (this) {
    requested => 0,
    confirmed => 1,
    guaranteed || completed => 2,
    cancelled || noShow => -1,
  };

  /// Database value (`no_show` instead of `noShow`).
  String get dbValue => this == noShow ? 'no_show' : name;

  static BookingStatus fromDb(String v) =>
      v == 'no_show' ? noShow : BookingStatus.values.byName(v);
}
