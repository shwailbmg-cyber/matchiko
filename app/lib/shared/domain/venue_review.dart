import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/player.dart';

part 'venue_review.freezed.dart';

/// A player asking to referee at my venue (`referee_applications`).
@freezed
abstract class RefApplication with _$RefApplication {
  const factory RefApplication({required String id, required Player player}) =
      _RefApplication;
}

/// A report about a game at my venue, waiting for my decision.
@freezed
abstract class VenueReport with _$VenueReport {
  const factory VenueReport({
    required int id,
    required String reporterName,
    required Player reported,
    required ReportReason reason,
    @Default('') String note,
    required DateTime gameStartsAt,
  }) = _VenueReport;
}
