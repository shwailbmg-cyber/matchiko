/// Amenities a pitch can have (`pitches.features` in the database).
enum Feature { light, ball, shower, roof, ref }

/// A bookable pitch at a venue.
class Pitch {
  const Pitch({
    required this.id,
    required this.venue,
    required this.venueAr,
    required this.district,
    required this.km,
    required this.rating,
    required this.reviews,
    required this.maxPerSide,
    required this.priceDa,
    required this.features,
  });

  final String id;
  final String venue;
  final String venueAr;
  final String district;
  final double km;
  final double rating;
  final int reviews;

  /// Largest game the pitch fits (players per side).
  final int maxPerSide;
  final int priceDa;
  final Set<Feature> features;

  String name(String languageCode) => languageCode == 'ar' ? venueAr : venue;
}

/// One hour on a pitch.
enum SlotState { free, booked, pending }

class Slot {
  const Slot(this.startsAt, this.state);

  final DateTime startsAt;
  final SlotState state;
}
