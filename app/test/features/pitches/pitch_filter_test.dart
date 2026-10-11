import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/features/pitches/domain/pitch_filter.dart';
import 'package:matchiko/shared/domain/pitch.dart';

void main() {
  const p = Pitch(
    id: 'p',
    venue: 'V',
    venueAr: 'V',
    district: 'D',
    km: 1,
    rating: 4.5,
    reviews: 10,
    maxPerSide: 7,
    priceDa: 2500,
    features: {Feature.light, Feature.shower},
  );

  test('empty filter matches everything', () {
    expect(const PitchFilter().isEmpty, isTrue);
    expect(const PitchFilter().matches(p, {}), isTrue);
  });

  test('size, price, amenities and favourites all apply', () {
    expect(const PitchFilter(minPerSide: 7).matches(p, {}), isTrue);
    expect(const PitchFilter(minPerSide: 11).matches(p, {}), isFalse);
    expect(const PitchFilter(maxPriceDa: 2500).matches(p, {}), isTrue);
    expect(const PitchFilter(maxPriceDa: 2000).matches(p, {}), isFalse);
    expect(const PitchFilter(features: {Feature.light}).matches(p, {}), isTrue);
    expect(const PitchFilter(features: {Feature.roof}).matches(p, {}), isFalse);
    expect(const PitchFilter(favoritesOnly: true).matches(p, {}), isFalse);
    expect(const PitchFilter(favoritesOnly: true).matches(p, {'p'}), isTrue);
  });
}
