import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/domain/models/cost_share.dart';

void main() {
  test('everyone pays when the split is already round', () {
    final s = CostShare.split(priceDa: 2500, players: 10, goalkeepers: 2);
    expect(
      (s.perPlayer, s.payers, s.goalkeepersFree, s.balance),
      (250, 10, false, 0),
    );
  });

  test('goalkeepers play free when that makes it round', () {
    // 2400 / 14 = 171.4 → not round; 2400 / 12 outfield = 200.
    final s = CostShare.split(priceDa: 2400, players: 14, goalkeepers: 2);
    expect(
      (s.perPlayer, s.payers, s.goalkeepersFree, s.balance),
      (200, 12, true, 0),
    );
  });

  test('rounds to the nearest 50 and shows the difference', () {
    // 2500 / 12 outfield = 208.3 → 200; booker adds 100.
    final s = CostShare.split(priceDa: 2500, players: 14, goalkeepers: 2);
    expect((s.perPlayer, s.payers, s.balance), (200, 12, -100));
    // 3000 / 20 outfield = 150 exactly after removing keepers.
    final t = CostShare.split(priceDa: 3000, players: 22, goalkeepers: 2);
    expect((t.perPlayer, t.payers, t.balance), (150, 20, 0));
  });

  test('every share is a multiple of 50', () {
    for (var price = 1000; price <= 6000; price += 100) {
      for (var n = 6; n <= 22; n += 2) {
        final s = CostShare.split(priceDa: price, players: n, goalkeepers: 2);
        expect(s.perPlayer % 50, 0, reason: '$price / $n');
        expect(s.balance.abs(), lessThan(25 * s.payers + 1));
      }
    }
  });
}
