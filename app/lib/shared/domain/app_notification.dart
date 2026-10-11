import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// `notifications.kind`. Unknown kinds from a newer server show as [other].
enum NotificationKind {
  @JsonValue('still_coming')
  stillComing,
  @JsonValue('spot_open')
  spotOpen,
  @JsonValue('booking_confirmed')
  bookingConfirmed,
  @JsonValue('rate_game')
  rateGame,
  @JsonValue('friend_request')
  friendRequest,
  other,
}

/// One row of `public.notifications` (own rows only).
@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required int id,
    @JsonKey(unknownEnumValue: NotificationKind.other)
    required NotificationKind kind,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    DateTime? readAt,
    required DateTime createdAt,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      _$AppNotificationFromJson(json);

  bool get unread => readAt == null;

  /// Payload values are data from the server, shown as plain text only.
  String text(String key) => payload[key]?.toString() ?? '';
}

/// Why a player is reported (`public.report_reason`).
enum ReportReason {
  @JsonValue('no_show')
  noShow,
  late,
  rude,
  unsafe,
  other,
}
