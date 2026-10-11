import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/profile.dart';
import '../../../core/view_model.dart';

class ProfileViewModel extends LoadingViewModel {
  ProfileViewModel(this._repo) : super(_repo);

  final GameRepository _repo;
  Profile? me;

  @override
  Future<void> fetch() async => me = await _repo.me();
}
