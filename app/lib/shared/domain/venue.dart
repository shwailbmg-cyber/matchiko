import 'package:freezed_annotation/freezed_annotation.dart';

part 'venue.freezed.dart';

/// The manager's venue: name and opening hours (`venues`).
@freezed
abstract class Venue with _$Venue {
  const factory Venue({
    required String id,
    required String name,
    @Default(8) int openHour,

    /// 24 = midnight.
    @Default(24) int closeHour,
  }) = _Venue;
}
