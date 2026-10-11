import '../../../../data/repositories/game_repository.dart';
import '../../../../domain/models/pitch.dart';
import '../../../core/view_model.dart';

class PitchViewModel extends LoadingViewModel {
  PitchViewModel(this._repo, this.pitchId, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now,
      super(_repo);

  final GameRepository _repo;
  final String pitchId;
  final DateTime Function() _clock;

  Pitch? pitch;
  int dayIndex = 0;
  List<Slot> slots = [];
  Slot? selected;
  int perSide = 0;
  bool withReferee = false;
  bool booking = false;

  static const refereeFee = 200;

  DateTime dayAt(int i) {
    final n = _clock();
    return DateTime(n.year, n.month, n.day + i);
  }

  int get total => (pitch?.priceDa ?? 0) + (withReferee ? refereeFee : 0);

  @override
  Future<void> fetch() async {
    pitch = await _repo.pitch(pitchId);
    if (perSide == 0) perSide = pitch!.maxPerSide;
    slots = await _repo.slots(pitchId, dayAt(dayIndex));
    if (selected != null &&
        !slots.any(
          (s) => s.startsAt == selected!.startsAt && s.state == SlotState.free,
        )) {
      selected = null;
    }
  }

  Future<void> pickDay(int i) async {
    dayIndex = i;
    selected = null;
    slots = await _repo.slots(pitchId, dayAt(i));
    changed();
  }

  void pick(Slot s) {
    if (s.state != SlotState.free) return;
    selected = selected?.startsAt == s.startsAt ? null : s;
    changed();
  }

  void setSize(int n) {
    perSide = n;
    changed();
  }

  void toggleReferee() {
    withReferee = !withReferee;
    changed();
  }

  /// Returns the new game id. Throws [NotVerifiedException].
  Future<String> book() async {
    booking = true;
    changed();
    try {
      return await _repo.requestBooking(
        pitchId: pitchId,
        startsAt: selected!.startsAt,
        perSide: perSide,
        withReferee: withReferee,
      );
    } finally {
      booking = false;
      changed();
    }
  }
}
