import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/rank.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String name,
    required String handle,
    required int xp,
    required int coins,
    required bool verified,
    required List<Position> positions,
    required int reliability,
    required int played,
    required int wins,
    required int goals,
    @Default(false) bool isReferee,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) =>
      _$ProfileFromJson(json);

  Rank get rank => Rank.fromXp(xp);

  String get initials => initialsOf(name);
}

/// First letters of the first two words ("Amine Bensaid" → "AB").
String initialsOf(String name) =>
    name.split(' ').where((w) => w.isNotEmpty).map((w) => w[0]).take(2).join();
