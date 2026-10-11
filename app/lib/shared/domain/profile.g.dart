// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  name: json['name'] as String,
  handle: json['handle'] as String,
  xp: (json['xp'] as num).toInt(),
  coins: (json['coins'] as num).toInt(),
  verified: json['verified'] as bool,
  positions: (json['positions'] as List<dynamic>)
      .map((e) => $enumDecode(_$PositionEnumMap, e))
      .toList(),
  reliability: (json['reliability'] as num).toInt(),
  played: (json['played'] as num).toInt(),
  wins: (json['wins'] as num).toInt(),
  goals: (json['goals'] as num).toInt(),
  isReferee: json['is_referee'] as bool? ?? false,
  wilayaId: json['wilaya_id'] as String?,
  level: $enumDecodeNullable(_$LevelEnumMap, json['level']),
  phone: json['phone'] as String?,
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'name': instance.name,
  'handle': instance.handle,
  'xp': instance.xp,
  'coins': instance.coins,
  'verified': instance.verified,
  'positions': instance.positions.map((e) => _$PositionEnumMap[e]!).toList(),
  'reliability': instance.reliability,
  'played': instance.played,
  'wins': instance.wins,
  'goals': instance.goals,
  'is_referee': instance.isReferee,
  'wilaya_id': instance.wilayaId,
  'level': _$LevelEnumMap[instance.level],
  'phone': instance.phone,
};

const _$PositionEnumMap = {
  Position.gk: 'gk',
  Position.def: 'def',
  Position.mid: 'mid',
  Position.fwd: 'fwd',
  Position.ref: 'ref',
};

const _$LevelEnumMap = {
  Level.beginner: 'beginner',
  Level.casual: 'casual',
  Level.good: 'good',
  Level.competitive: 'competitive',
};
