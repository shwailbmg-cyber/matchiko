import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/game.dart';
import '../../../../domain/models/position.dart';

enum PlayMode { solo, friends, team }

enum TimeWindow { morning, afternoon, evening, night }

enum PlayStage { form, searching, found, none }

/// Find-a-game flow: preferences → searching → 30 s offer → joined.
class PlayViewModel extends ChangeNotifier {
  PlayViewModel(
    this._repo, {
    this.searchTime = const Duration(milliseconds: 2400),
    this.offerTime = 30,
  });

  final GameRepository _repo;
  final Duration searchTime;

  /// Seconds to accept an offer.
  final int offerTime;

  PlayMode mode = PlayMode.solo;
  final positions = <Position>[Position.mid, Position.fwd];
  int day = 0;
  final windows = <TimeWindow>{TimeWindow.evening};
  double radiusKm = 5;
  bool referee = false;

  PlayStage stage = PlayStage.form;
  int step = 0;
  int secondsLeft = 0;
  Game? offer;
  Timer? _timer;
  bool _disposed = false;

  void _n() {
    if (!_disposed) notifyListeners();
  }

  void setMode(PlayMode m) {
    mode = m;
    _n();
  }

  /// Tap order = preference order; at least one position stays.
  void togglePosition(Position p) {
    if (positions.contains(p)) {
      if (positions.length > 1) positions.remove(p);
    } else {
      positions.add(p);
    }
    _n();
  }

  void setDay(int d) {
    day = d;
    _n();
  }

  void toggleWindow(TimeWindow w) {
    if (windows.contains(w)) {
      if (windows.length > 1) windows.remove(w);
    } else {
      windows.add(w);
    }
    _n();
  }

  void setRadius(double km) {
    radiusKm = km;
    _n();
  }

  void toggleReferee() {
    referee = !referee;
    _n();
  }

  Future<void> search() async {
    _timer?.cancel();
    stage = PlayStage.searching;
    step = 0;
    _n();
    final stepTime = searchTime ~/ 4;
    _timer = Timer.periodic(stepTime, (t) {
      if (step < 4) {
        step++;
        _n();
      }
    });
    final results = await Future.wait([
      _repo.findGame(positions: positions),
      Future<void>.delayed(searchTime),
    ]);
    _timer?.cancel();
    if (_disposed || stage != PlayStage.searching) return;
    offer = results[0] as Game?;
    if (offer == null) {
      stage = PlayStage.none;
      _n();
      return;
    }
    stage = PlayStage.found;
    secondsLeft = offerTime;
    _n();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        t.cancel();
        reset();
      } else {
        _n();
      }
    });
  }

  /// Joins the offered game; returns its id for navigation.
  Future<String?> accept() async {
    final g = offer;
    if (g == null) return null;
    _timer?.cancel();
    await _repo.joinGame(g.id, positions.first);
    reset();
    return g.id;
  }

  void reset() {
    _timer?.cancel();
    stage = PlayStage.form;
    offer = null;
    _n();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
