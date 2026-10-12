// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'venue_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VenueStats _$VenueStatsFromJson(Map<String, dynamic> json) => _VenueStats(
  bookings: (json['bookings'] as num?)?.toInt() ?? 0,
  requested: (json['requested'] as num?)?.toInt() ?? 0,
  confirmed: (json['confirmed'] as num?)?.toInt() ?? 0,
  guaranteed: (json['guaranteed'] as num?)?.toInt() ?? 0,
  completed: (json['completed'] as num?)?.toInt() ?? 0,
  cancelled: (json['cancelled'] as num?)?.toInt() ?? 0,
  noShows: (json['no_shows'] as num?)?.toInt() ?? 0,
  walkIns: (json['walk_ins'] as num?)?.toInt() ?? 0,
  cashExpectedDa: (json['cash_expected_da'] as num?)?.toInt() ?? 0,
  cashReceivedDa: (json['cash_received_da'] as num?)?.toInt() ?? 0,
  bookedHours: (json['booked_hours'] as num?)?.toInt() ?? 0,
  openHours: (json['open_hours'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$VenueStatsToJson(_VenueStats instance) =>
    <String, dynamic>{
      'bookings': instance.bookings,
      'requested': instance.requested,
      'confirmed': instance.confirmed,
      'guaranteed': instance.guaranteed,
      'completed': instance.completed,
      'cancelled': instance.cancelled,
      'no_shows': instance.noShows,
      'walk_ins': instance.walkIns,
      'cash_expected_da': instance.cashExpectedDa,
      'cash_received_da': instance.cashReceivedDa,
      'booked_hours': instance.bookedHours,
      'open_hours': instance.openHours,
    };
