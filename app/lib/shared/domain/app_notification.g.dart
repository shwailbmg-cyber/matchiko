// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: (json['id'] as num).toInt(),
      kind: $enumDecode(
        _$NotificationKindEnumMap,
        json['kind'],
        unknownValue: NotificationKind.other,
      ),
      payload:
          json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'kind': _$NotificationKindEnumMap[instance.kind]!,
      'payload': instance.payload,
      'read_at': instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$NotificationKindEnumMap = {
  NotificationKind.stillComing: 'still_coming',
  NotificationKind.spotOpen: 'spot_open',
  NotificationKind.bookingConfirmed: 'booking_confirmed',
  NotificationKind.rateGame: 'rate_game',
  NotificationKind.friendRequest: 'friend_request',
  NotificationKind.other: 'other',
};
