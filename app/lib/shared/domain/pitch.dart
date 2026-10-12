import 'package:freezed_annotation/freezed_annotation.dart';

part 'pitch.freezed.dart';
part 'pitch.g.dart';

/// Amenities a pitch can have (`pitches.features` in the database).
enum Feature { light, ball, shower, roof, ref }

/// A bookable pitch at a venue.
@freezed
abstract class Pitch with _$Pitch {
  const Pitch._();

  const factory Pitch({
    required String id,
    required String venue,
    required String venueAr,
    required String district,
    required double km,
    required double rating,
    required int reviews,

    /// Largest game the pitch fits (players per side).
    required int maxPerSide,
    required int priceDa,
    required Set<Feature> features,

    /// Inactive pitches are hidden from players.
    @Default(true) bool active,
  }) = _Pitch;

  factory Pitch.fromJson(Map<String, dynamic> json) => _$PitchFromJson(json);

  String name(String languageCode) => languageCode == 'ar' ? venueAr : venue;
}

/// One hour on a pitch.
enum SlotState { free, booked, pending }

@freezed
abstract class Slot with _$Slot {
  const factory Slot(DateTime startsAt, SlotState state) = _Slot;

  factory Slot.fromJson(Map<String, dynamic> json) => _$SlotFromJson(json);
}
