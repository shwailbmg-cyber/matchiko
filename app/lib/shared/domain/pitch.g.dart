// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pitch.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Pitch _$PitchFromJson(Map<String, dynamic> json) => _Pitch(
  id: json['id'] as String,
  venue: json['venue'] as String,
  venueAr: json['venue_ar'] as String,
  district: json['district'] as String,
  km: (json['km'] as num).toDouble(),
  rating: (json['rating'] as num).toDouble(),
  reviews: (json['reviews'] as num).toInt(),
  maxPerSide: (json['max_per_side'] as num).toInt(),
  priceDa: (json['price_da'] as num).toInt(),
  features: (json['features'] as List<dynamic>)
      .map((e) => $enumDecode(_$FeatureEnumMap, e))
      .toSet(),
  active: json['active'] as bool? ?? true,
);

Map<String, dynamic> _$PitchToJson(_Pitch instance) => <String, dynamic>{
  'id': instance.id,
  'venue': instance.venue,
  'venue_ar': instance.venueAr,
  'district': instance.district,
  'km': instance.km,
  'rating': instance.rating,
  'reviews': instance.reviews,
  'max_per_side': instance.maxPerSide,
  'price_da': instance.priceDa,
  'features': instance.features.map((e) => _$FeatureEnumMap[e]!).toList(),
  'active': instance.active,
};

const _$FeatureEnumMap = {
  Feature.light: 'light',
  Feature.ball: 'ball',
  Feature.shower: 'shower',
  Feature.roof: 'roof',
  Feature.ref: 'ref',
};

_Slot _$SlotFromJson(Map<String, dynamic> json) => _Slot(
  DateTime.parse(json['starts_at'] as String),
  $enumDecode(_$SlotStateEnumMap, json['state']),
);

Map<String, dynamic> _$SlotToJson(_Slot instance) => <String, dynamic>{
  'starts_at': instance.startsAt.toIso8601String(),
  'state': _$SlotStateEnumMap[instance.state]!,
};

const _$SlotStateEnumMap = {
  SlotState.free: 'free',
  SlotState.booked: 'booked',
  SlotState.pending: 'pending',
};
