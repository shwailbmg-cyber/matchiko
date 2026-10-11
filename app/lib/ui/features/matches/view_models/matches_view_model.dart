import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/game.dart';
import '../../../core/view_model.dart';

class MatchesViewModel extends LoadingViewModel {
  MatchesViewModel(this._repo) : super(_repo);

  final GameRepository _repo;

  bool showPast = false;
  List<Game> upcoming = [];
  List<Game> past = [];
  final rated = <String>{};

  @override
  Future<void> fetch() async {
    final r = await Future.wait([_repo.myUpcoming(), _repo.myPast()]);
    upcoming = r[0];
    past = r[1];
  }

  void setTab({required bool past}) {
    showPast = past;
    changed();
  }

  /// Ratings go to `rate_game()` with the Supabase repository (M5).
  void rate(String gameId) {
    rated.add(gameId);
    changed();
  }
}
