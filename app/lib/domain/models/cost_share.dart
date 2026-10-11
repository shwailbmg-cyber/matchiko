/// How much each player pays the booker for the pitch, in round DA amounts
/// (multiples of 50, like real notes and coins). Display only: no money moves
/// in the app.
///
/// Rule (product decision):
/// 1. If price ÷ all players is a multiple of 50, everyone pays that.
/// 2. Otherwise goalkeepers play for free and the outfield players share it.
/// 3. If that still isn't a multiple of 50, round to the nearest 50; the
///    small difference ([balance]) is shown to the booker.
class CostShare {
  const CostShare({
    required this.perPlayer,
    required this.payers,
    required this.goalkeepersFree,
    required this.balance,
  });

  final int perPlayer;
  final int payers;
  final bool goalkeepersFree;

  /// Collected minus price: positive = extra for the booker, negative = the
  /// booker adds that much.
  final int balance;

  static const step = 50;

  factory CostShare.split({
    required int priceDa,
    required int players,
    int goalkeepers = 0,
  }) {
    if (priceDa <= 0 || players <= 0) {
      throw ArgumentError('price and players must be positive');
    }
    if (priceDa % (players * step) == 0) {
      return CostShare(
        perPlayer: priceDa ~/ players,
        payers: players,
        goalkeepersFree: false,
        balance: 0,
      );
    }
    final free = goalkeepers > 0 && goalkeepers < players;
    final payers = free ? players - goalkeepers : players;
    final perPlayer = ((priceDa / payers / step).round() * step).clamp(
      step,
      priceDa,
    );
    return CostShare(
      perPlayer: perPlayer,
      payers: payers,
      goalkeepersFree: free,
      balance: perPlayer * payers - priceDa,
    );
  }
}
