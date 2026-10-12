import 'package:freezed_annotation/freezed_annotation.dart';

part 'my_settings.freezed.dart';

/// Who can see the games I play (`profiles.games_visibility`).
enum GamesVisibility { everyone, friends, nobody }

/// My private settings (`get_my_settings`).
@freezed
abstract class MySettings with _$MySettings {
  const factory MySettings({
    @Default(true) bool notifyNearby,
    @Default(true) bool notifyReminders,
    @Default(GamesVisibility.friends) GamesVisibility visibility,
  }) = _MySettings;
}
