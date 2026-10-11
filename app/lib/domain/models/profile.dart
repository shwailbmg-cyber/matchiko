import 'position.dart';
import 'rank.dart';

class Profile {
  const Profile({
    required this.name,
    required this.handle,
    required this.xp,
    required this.coins,
    required this.verified,
    required this.positions,
    required this.reliability,
    required this.played,
    required this.wins,
    required this.goals,
    this.isReferee = false,
  });

  final String name;
  final String handle;
  final int xp;
  final int coins;
  final bool verified;
  final List<Position> positions;
  final int reliability;
  final int played;
  final int wins;
  final int goals;
  final bool isReferee;

  Rank get rank => Rank.fromXp(xp);

  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0])
      .take(2)
      .join();

  Profile copyWith({bool? verified, int? xp, int? coins}) => Profile(
    name: name,
    handle: handle,
    xp: xp ?? this.xp,
    coins: coins ?? this.coins,
    verified: verified ?? this.verified,
    positions: positions,
    reliability: reliability,
    played: played,
    wins: wins,
    goals: goals,
    isReferee: isReferee,
  );
}
