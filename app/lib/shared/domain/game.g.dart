// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_GamePlayer _$GamePlayerFromJson(Map<String, dynamic> json) => _GamePlayer(
  name: json['name'] as String,
  handle: json['handle'] as String,
  position: $enumDecode(_$PositionEnumMap, json['position']),
  team: $enumDecode(_$SideEnumMap, json['team']),
  reliability: (json['reliability'] as num?)?.toInt() ?? 100,
  paid: json['paid'] as bool? ?? false,
  confirmed: json['confirmed'] as bool? ?? true,
  guest: json['guest'] as bool? ?? false,
  isMe: json['is_me'] as bool? ?? false,
  isBooker: json['is_booker'] as bool? ?? false,
);

Map<String, dynamic> _$GamePlayerToJson(_GamePlayer instance) =>
    <String, dynamic>{
      'name': instance.name,
      'handle': instance.handle,
      'position': _$PositionEnumMap[instance.position]!,
      'team': _$SideEnumMap[instance.team]!,
      'reliability': instance.reliability,
      'paid': instance.paid,
      'confirmed': instance.confirmed,
      'guest': instance.guest,
      'is_me': instance.isMe,
      'is_booker': instance.isBooker,
    };

const _$PositionEnumMap = {
  Position.gk: 'gk',
  Position.def: 'def',
  Position.mid: 'mid',
  Position.fwd: 'fwd',
  Position.ref: 'ref',
};

const _$SideEnumMap = {Side.a: 'a', Side.b: 'b'};

_Game _$GameFromJson(Map<String, dynamic> json) => _Game(
  id: json['id'] as String,
  pitch: Pitch.fromJson(json['pitch'] as Map<String, dynamic>),
  startsAt: DateTime.parse(json['starts_at'] as String),
  perSide: (json['per_side'] as num).toInt(),
  status: $enumDecode(_$BookingStatusEnumMap, json['status']),
  players: (json['players'] as List<dynamic>)
      .map((e) => GamePlayer.fromJson(e as Map<String, dynamic>))
      .toList(),
  open: json['open'] as bool? ?? false,
  waitlist: (json['waitlist'] as num?)?.toInt() ?? 0,
  competitive: json['competitive'] as bool? ?? false,
  code: json['code'] as String? ?? '',
);

Map<String, dynamic> _$GameToJson(_Game instance) => <String, dynamic>{
  'id': instance.id,
  'pitch': instance.pitch.toJson(),
  'starts_at': instance.startsAt.toIso8601String(),
  'per_side': instance.perSide,
  'status': _$BookingStatusEnumMap[instance.status]!,
  'players': instance.players.map((e) => e.toJson()).toList(),
  'open': instance.open,
  'waitlist': instance.waitlist,
  'competitive': instance.competitive,
  'code': instance.code,
};

const _$BookingStatusEnumMap = {
  BookingStatus.requested: 'requested',
  BookingStatus.confirmed: 'confirmed',
  BookingStatus.guaranteed: 'guaranteed',
  BookingStatus.completed: 'completed',
  BookingStatus.cancelled: 'cancelled',
  BookingStatus.noShow: 'no_show',
};
