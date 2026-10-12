import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/features/play/presentation/play_controller.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/providers.dart';

void main() {
  late ProviderContainer c;
  PlayController ctrl() => c.read(playControllerProvider.notifier);
  PlayState state() => c.read(playControllerProvider);

  setUp(() {
    c = ProviderContainer(
      overrides: [
        gameRepositoryProvider.overrideWithValue(DemoGameRepository()),
      ],
    );
    // Keep the auto-dispose provider alive during the test.
    c.listen(playControllerProvider, (_, _) {});
  });
  tearDown(() => c.dispose());

  test('positions keep tap order and never go empty', () {
    ctrl().togglePosition(Position.gk);
    expect(state().positions, [Position.mid, Position.fwd, Position.gk]);
    ctrl().togglePosition(Position.mid);
    ctrl().togglePosition(Position.fwd);
    ctrl().togglePosition(Position.gk);
    expect(state().positions, [Position.gk]);
  });

  test('join as keeper only while the game has room for one', () async {
    final g = (await DemoGameRepository().openGames()).first;
    final keepers = g.goalkeepers;
    expect(
      positionFor(g, [Position.gk, Position.def]),
      keepers < 2 ? Position.gk : Position.def,
    );
    final full = g.copyWith(
      players: [
        for (final p in g.players.take(2)) p.copyWith(position: Position.gk),
      ],
    );
    expect(positionFor(full, [Position.gk, Position.def]), Position.def);
    expect(positionFor(full, [Position.gk]), Position.mid);
  });

  test('at least one time window stays selected', () {
    ctrl().toggleWindow(TimeWindow.evening);
    expect(state().windows, {TimeWindow.evening});
    ctrl().toggleWindow(TimeWindow.night);
    ctrl().toggleWindow(TimeWindow.evening);
    expect(state().windows, {TimeWindow.night});
  });

  test('search finds an offer, accept joins it', () async {
    await ctrl().search();
    expect(state().stage, PlayStage.found);
    expect(state().secondsLeft, PlayController.offerTime);
    final id = await ctrl().accept();
    expect(id, isNotNull);
    expect(state().stage, PlayStage.form);
    final game = await c.read(gameRepositoryProvider).game(id!);
    expect(game.me, isNotNull);
  });
}
