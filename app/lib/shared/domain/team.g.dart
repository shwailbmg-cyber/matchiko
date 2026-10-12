// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'team.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Team _$TeamFromJson(Map<String, dynamic> json) => _Team(
  id: json['id'] as String,
  name: json['name'] as String,
  perSide: (json['per_side'] as num).toInt(),
  captainHandle: json['captain_handle'] as String,
  members:
      (json['members'] as List<dynamic>?)
          ?.map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Player>[],
  iAmCaptain: json['i_am_captain'] as bool? ?? false,
  usualWeekday: (json['usual_weekday'] as num?)?.toInt(),
  usualHour: (json['usual_hour'] as num?)?.toInt(),
  usualPitchId: json['usual_pitch_id'] as String?,
  wins: (json['wins'] as num?)?.toInt() ?? 0,
  draws: (json['draws'] as num?)?.toInt() ?? 0,
  losses: (json['losses'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$TeamToJson(_Team instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'per_side': instance.perSide,
  'captain_handle': instance.captainHandle,
  'members': instance.members.map((e) => e.toJson()).toList(),
  'i_am_captain': instance.iAmCaptain,
  'usual_weekday': instance.usualWeekday,
  'usual_hour': instance.usualHour,
  'usual_pitch_id': instance.usualPitchId,
  'wins': instance.wins,
  'draws': instance.draws,
  'losses': instance.losses,
};
