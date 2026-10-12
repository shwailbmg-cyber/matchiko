// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Player _$PlayerFromJson(Map<String, dynamic> json) => _Player(
  handle: json['handle'] as String,
  name: json['name'] as String,
  wilayaId: json['wilaya_id'] as String?,
  positions:
      (json['positions'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PositionEnumMap, e))
          .toList() ??
      const <Position>[],
  xp: (json['xp'] as num?)?.toInt() ?? 0,
  verified: json['verified'] as bool? ?? false,
  played: (json['played'] as num?)?.toInt() ?? 0,
  friend:
      $enumDecodeNullable(_$FriendStatusEnumMap, json['friend']) ??
      FriendStatus.none,
);

Map<String, dynamic> _$PlayerToJson(_Player instance) => <String, dynamic>{
  'handle': instance.handle,
  'name': instance.name,
  'wilaya_id': instance.wilayaId,
  'positions': instance.positions.map((e) => _$PositionEnumMap[e]!).toList(),
  'xp': instance.xp,
  'verified': instance.verified,
  'played': instance.played,
  'friend': _$FriendStatusEnumMap[instance.friend]!,
};

const _$PositionEnumMap = {
  Position.gk: 'gk',
  Position.def: 'def',
  Position.mid: 'mid',
  Position.fwd: 'fwd',
  Position.ref: 'ref',
};

const _$FriendStatusEnumMap = {
  FriendStatus.none: 'none',
  FriendStatus.sent: 'sent',
  FriendStatus.incoming: 'incoming',
  FriendStatus.friends: 'friends',
};
