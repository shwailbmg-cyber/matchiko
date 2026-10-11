import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/booking_status.dart';
import '../../../../domain/models/game.dart';
import '../../../../domain/models/profile.dart';
import '../../../core/view_model.dart';

class TodayViewModel extends LoadingViewModel {
  TodayViewModel(this._repo) : super(_repo);

  final GameRepository _repo;
  List<Game> games = [];

  int count(BookingStatus s) => games.where((g) => g.status == s).length;

  Game? at(int hour) => games.where((g) => g.startsAt.hour == hour).firstOrNull;

  @override
  Future<void> fetch() async => games = await _repo.venueToday();

  Future<void> confirm(String id) => _repo.confirmBooking(id);
  Future<void> noShow(String id) => _repo.markNoShow(id);
}

class ScanViewModel extends LoadingViewModel {
  ScanViewModel(this._repo) : super(_repo);

  final GameRepository _repo;
  List<Game> waiting = [];
  Game? scanned;
  bool cashReceived = false;

  /// Demo stand-in for the camera: the next booking waiting for payment.
  Game? get nextToScan => waiting.firstOrNull;

  @override
  Future<void> fetch() async => waiting = (await _repo.venueToday())
      .where((g) => g.status == BookingStatus.confirmed)
      .toList();

  void simulateScan() {
    scanned = nextToScan;
    cashReceived = false;
    changed();
  }

  void toggleCash() {
    cashReceived = !cashReceived;
    changed();
  }

  Future<void> markGuaranteed() async {
    final g = scanned;
    if (g == null || !cashReceived) return;
    await _repo.scanBooking(g.code);
    scanned = null;
    changed();
  }

  void close() {
    scanned = null;
    changed();
  }
}

class PlayersViewModel extends LoadingViewModel {
  PlayersViewModel(this._repo) : super(_repo);

  final GameRepository _repo;
  List<Profile> queue = [];
  final checks = <String, Set<int>>{};

  @override
  Future<void> fetch() async => queue = await _repo.verificationQueue();

  bool checked(String handle, int i) => checks[handle]?.contains(i) ?? false;

  void toggle(String handle, int i) {
    final s = checks.putIfAbsent(handle, () => {});
    s.contains(i) ? s.remove(i) : s.add(i);
    changed();
  }

  /// Name, photo and age checked in person.
  bool ready(String handle) => (checks[handle]?.length ?? 0) == 3;

  Future<void> verify(String handle) => _repo.verifyPlayer(handle);
}
