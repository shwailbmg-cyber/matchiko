import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/pitch.dart';

part 'pitch_filter.freezed.dart';

/// Filters on the pitch list. Display only: the server returns what the
/// player may book either way.
@freezed
abstract class PitchFilter with _$PitchFilter {
  const PitchFilter._();

  const factory PitchFilter({
    /// Pitch must fit at least this many players per side (null = any).
    int? minPerSide,

    /// Price per hour at most (null = any).
    int? maxPriceDa,
    @Default(<Feature>{}) Set<Feature> features,
    @Default(false) bool favoritesOnly,
  }) = _PitchFilter;

  bool get isEmpty => this == const PitchFilter();

  bool matches(Pitch p, Set<String> favorites) =>
      (minPerSide == null || p.maxPerSide >= minPerSide!) &&
      (maxPriceDa == null || p.priceDa <= maxPriceDa!) &&
      p.features.containsAll(features) &&
      (!favoritesOnly || favorites.contains(p.id));
}
