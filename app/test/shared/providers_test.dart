import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/providers.dart';

void main() {
  test('data providers refetch after any repository change', () async {
    final repo = DemoGameRepository();
    final c = ProviderContainer(
      overrides: [gameRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    c.listen(meProvider, (_, _) {});

    final before = await c.read(meProvider.future);
    await repo.cancelBooking('g1'); // −20 XP, −10 coins
    await Future<void>.delayed(Duration.zero);
    final after = await c.read(meProvider.future);

    expect(after.xp, before.xp - 20);
    expect(after.coins, before.coins - 10);
  });
}
