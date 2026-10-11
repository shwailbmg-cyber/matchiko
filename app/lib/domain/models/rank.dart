/// Rank tiers driven by Rank XP (can't be spent). Mirrors `public.rank_of()`
/// in the database so the app and server always agree.
enum Rank {
  bronze('🥉', 0),
  silver('🥈', 500),
  gold('🥇', 1000),
  elite('💎', 2000),
  legend('👑', 3500);

  const Rank(this.emoji, this.minXp);

  final String emoji;
  final int minXp;

  static Rank fromXp(int xp) =>
      values.lastWhere((r) => xp >= r.minXp, orElse: () => bronze);

  /// Next tier, or null at Legend.
  Rank? get next => index + 1 < values.length ? values[index + 1] : null;

  /// 0..1 progress from this tier to the next.
  static double progress(int xp) {
    final r = fromXp(xp);
    final n = r.next;
    if (n == null) return 1;
    return ((xp - r.minXp) / (n.minXp - r.minXp)).clamp(0, 1).toDouble();
  }
}
