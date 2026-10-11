import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/game.dart';
import '../../../../domain/models/pitch.dart';
import '../../../../domain/models/profile.dart';
import '../../../core/view_model.dart';

class HomeViewModel extends LoadingViewModel {
  HomeViewModel(this._repo) : super(_repo);

  final GameRepository _repo;

  Profile? me;
  int live = 0;
  List<Game> openGames = [];
  List<Pitch> pitches = [];
  String query = '';

  @override
  Future<void> fetch() async {
    final r = await Future.wait([
      _repo.me(),
      _repo.liveSearching(),
      _repo.openGames(),
      _repo.pitches(query: query),
    ]);
    me = r[0] as Profile;
    live = r[1] as int;
    openGames = r[2] as List<Game>;
    pitches = r[3] as List<Pitch>;
  }

  Future<void> search(String q) async {
    query = q;
    pitches = await _repo.pitches(query: q);
    changed();
  }
}
