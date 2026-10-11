import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/providers.dart';

part 'play_controller.freezed.dart';

enum PlayMode { solo, friends, team }

enum TimeWindow { morning, afternoon, evening, night }

enum PlayStage { form, searching, found, none }

@freezed
abstract class PlayState with _$PlayState {
  const factory PlayState({
    @Default(PlayMode.solo) PlayMode mode,

    /// Tap order = preference order.
    @Default([Position.mid, Position.fwd]) List<Position> positions,
    @Default(0) int day,
    @Default({TimeWindow.evening}) Set<TimeWindow> windows,
    @Default(5) double radiusKm,
    @Default(false) bool referee,
    @Default(PlayStage.form) PlayStage stage,

    /// Searching animation step, 0..4.
    @Default(0) int step,
    @Default(0) int secondsLeft,
    Game? offer,
  }) = _PlayState;
}

/// Find-a-game flow: preferences → searching → 30 s offer → joined.
class PlayController extends Notifier<PlayState> {
  /// How long the search animation lasts at least.
  static const searchTime = Duration(milliseconds: 2400);

  /// Seconds to accept an offer.
  static const offerTime = 30;

  Timer? _timer;

  @override
  PlayState build() {
    ref.onDispose(() => _timer?.cancel());
    return const PlayState();
  }

  void setMode(PlayMode m) => state = state.copyWith(mode: m);

  /// At least one position stays selected.
  void togglePosition(Position p) {
    final list = [...state.positions];
    if (list.contains(p)) {
      if (list.length > 1) list.remove(p);
    } else {
      list.add(p);
    }
    state = state.copyWith(positions: list);
  }

  void setDay(int d) => state = state.copyWith(day: d);

  /// At least one window stays selected.
  void toggleWindow(TimeWindow w) {
    final set = {...state.windows};
    if (set.contains(w)) {
      if (set.length > 1) set.remove(w);
    } else {
      set.add(w);
    }
    state = state.copyWith(windows: set);
  }

  void setRadius(double km) => state = state.copyWith(radiusKm: km);

  void toggleReferee() => state = state.copyWith(referee: !state.referee);

  Future<void> search() async {
    _timer?.cancel();
    state = state.copyWith(stage: PlayStage.searching, step: 0);
    _timer = Timer.periodic(searchTime ~/ 4, (_) {
      if (state.step < 4) state = state.copyWith(step: state.step + 1);
    });
    final results = await Future.wait([
      ref.read(gameRepositoryProvider).findGame(positions: state.positions),
      Future<void>.delayed(searchTime),
    ]);
    _timer?.cancel();
    if (!ref.mounted || state.stage != PlayStage.searching) return;
    final offer = results[0] as Game?;
    if (offer == null) {
      state = state.copyWith(stage: PlayStage.none);
      return;
    }
    state = state.copyWith(
      stage: PlayStage.found,
      offer: offer,
      secondsLeft: offerTime,
    );
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsLeft <= 1) {
        reset();
      } else {
        state = state.copyWith(secondsLeft: state.secondsLeft - 1);
      }
    });
  }

  /// Joins the offered game; returns its id for navigation.
  Future<String?> accept() async {
    final g = state.offer;
    if (g == null) return null;
    _timer?.cancel();
    await ref
        .read(gameRepositoryProvider)
        .joinGame(g.id, state.positions.first);
    if (ref.mounted) reset();
    return g.id;
  }

  void reset() {
    _timer?.cancel();
    state = state.copyWith(stage: PlayStage.form, offer: null);
  }
}

final playControllerProvider =
    NotifierProvider.autoDispose<PlayController, PlayState>(PlayController.new);
