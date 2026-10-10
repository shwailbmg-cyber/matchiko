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

/// Game size: players per side, from 3 up to 11. Common sizes are 5v5,
/// 6v6, 7v7, 8v8 and 11v11, but the booker can pick any size the pitch fits
/// (`pitches.max_per_side` / `games.per_side` in the database).
extension type const GameFormat(int perSide) {
  static const min = 3;
  static const max = 11;

  /// Sizes offered first in pickers.
  static const common = [
    GameFormat(5),
    GameFormat(6),
    GameFormat(7),
    GameFormat(8),
    GameFormat(11),
  ];

  bool get isValid => perSide >= min && perSide <= max;
  int get totalPlayers => perSide * 2;
  String get label => '${perSide}v$perSide';

  /// Default line-up used to place players on the pitch drawing: one keeper,
  /// then about 40 % defenders, 40 % midfielders, 20 % forwards
  /// (5 → 2-1-1, 6 → 2-2-1, 7 → 3-2-1, 8 → 3-3-1, 11 → 4-4-2).
  List<Position> get lineup {
    final outfield = perSide - 1;
    final fwd = (outfield * .2).round().clamp(1, outfield);
    final def = ((outfield - fwd) / 2).ceil();
    final mid = outfield - fwd - def;
    return [
      Position.gk,
      for (var i = 0; i < def; i++) Position.def,
      for (var i = 0; i < mid; i++) Position.mid,
      for (var i = 0; i < fwd; i++) Position.fwd,
    ];
  }
}
