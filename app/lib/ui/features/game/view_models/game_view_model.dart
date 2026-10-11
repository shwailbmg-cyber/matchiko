import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/game.dart';
import '../../../../domain/models/position.dart';
import '../../../core/view_model.dart';

class GameViewModel extends LoadingViewModel {
  GameViewModel(this._repo, this.gameId, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(_repo);

  final GameRepository _repo;
  final String gameId;
  final DateTime Function() _clock;

  Game? game;
  bool busy = false;

  @override
  Future<void> fetch() async => game = await _repo.game(gameId);

  Duration get timeLeft => game!.startsAt.difference(_clock());

  /// The "Still coming?" box shows in the last 24 h for players in the game.
  bool get showStillComing =>
      game?.me != null && timeLeft > Duration.zero && timeLeft.inHours < 24;

  bool get canJoin =>
      game != null && game!.me == null && game!.open && !game!.full;

  Future<void> _do(Future<void> Function() f) async {
    busy = true;
    changed();
    try {
      await f();
    } finally {
      busy = false;
      changed();
    }
  }

  Future<void> join(Position p) => _do(() => _repo.joinGame(gameId, p));
  Future<void> coming(bool yes) =>
      _do(() => _repo.confirmComing(gameId, coming: yes));
  Future<void> setOpen(bool v) => _do(() => _repo.setOpen(gameId, open: v));
  Future<void> setPaid(String handle, bool v) =>
      _do(() => _repo.setPaid(gameId, handle, paid: v));
  Future<void> setSize(int n) => _do(() => _repo.setGameSize(gameId, n));
  Future<void> cancel() => _do(() => _repo.cancelBooking(gameId));
}
