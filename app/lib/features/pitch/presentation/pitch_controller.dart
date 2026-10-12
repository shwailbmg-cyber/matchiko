import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/providers.dart';

part 'pitch_controller.freezed.dart';

/// Referee add-on, paid in cash to the referee (PRODUCT.md § Referee).
const refereeFeeDa = 200;

/// Midnight [index] days from today (0 = today).
DateTime dayAt(int index) {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day + index);
}

final pitchProvider = FutureProvider.autoDispose.family<Pitch, String>(
  (ref, id) => watchGames(ref).pitch(id),
);

final slotsProvider = FutureProvider.autoDispose
    .family<List<Slot>, ({String pitchId, int day})>(
      (ref, k) => watchGames(ref).slots(k.pitchId, dayAt(k.day)),
    );

/// What the player is picking on the pitch page before sending a request.
@freezed
abstract class BookingDraft with _$BookingDraft {
  const factory BookingDraft({
    @Default(0) int dayIndex,
    Slot? selected,

    /// Players per side; 0 means the pitch's maximum.
    @Default(0) int perSide,
    @Default(false) bool withReferee,
    @Default(false) bool sending,
  }) = _BookingDraft;
}

class PitchController extends Notifier<BookingDraft> {
  PitchController(this.pitchId);

  final String pitchId;

  @override
  BookingDraft build() => const BookingDraft();

  void pickDay(int i) => state = state.copyWith(dayIndex: i, selected: null);

  void pick(Slot s) {
    if (s.state != SlotState.free) return;
    final same = state.selected?.startsAt == s.startsAt;
    state = state.copyWith(selected: same ? null : s);
  }

  void setSize(int n) => state = state.copyWith(perSide: n);

  void toggleReferee() =>
      state = state.copyWith(withReferee: !state.withReferee);

  /// Sends the booking request; returns the new game id.
  /// Throws [NotVerifiedException] for unverified players.
  Future<String> book({required int perSide}) async {
    final slot = state.selected!;
    state = state.copyWith(sending: true);
    try {
      return await ref
          .read(gameRepositoryProvider)
          .requestBooking(
            pitchId: pitchId,
            startsAt: slot.startsAt,
            perSide: perSide,
            withReferee: state.withReferee,
          );
    } finally {
      if (ref.mounted) state = state.copyWith(sending: false);
    }
  }
}

final pitchControllerProvider = NotifierProvider.autoDispose
    .family<PitchController, BookingDraft, String>(PitchController.new);
