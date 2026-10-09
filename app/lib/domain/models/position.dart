/// Playing positions (plus referee) with their emoji badges.
/// Values match the `public.position` enum in the database.
enum Position {
  gk('🧤'),
  def('🛡️'),
  mid('🎯'),
  fwd('⚽'),
  ref('🟨');

  const Position(this.emoji);

  final String emoji;

  /// Positions a player can search for (referee is a separate role).
  static const playable = [gk, def, mid, fwd];
}

/// Game formats and the line-up used to place players on the pitch.
enum GameFormat {
  fiveASide(5, [
    Position.gk,
    Position.def,
    Position.def,
    Position.mid,
    Position.fwd,
  ]),
  sixASide(6, [
    Position.gk, Position.def, Position.def, //
    Position.mid, Position.mid, Position.fwd,
  ]),
  eightASide(8, [
    Position.gk, Position.def, Position.def, Position.def, //
    Position.mid, Position.mid, Position.mid, Position.fwd,
  ]);

  const GameFormat(this.perTeam, this.lineup);

  final int perTeam;
  final List<Position> lineup;

  int get totalPlayers => perTeam * 2;
  String get label => '${perTeam}v$perTeam';
}
