import 'package:freezed_annotation/freezed_annotation.dart';

part 'ledger_entry.freezed.dart';
part 'ledger_entry.g.dart';

/// Why XP or coins changed (`public.reward_reason`).
enum RewardReason {
  @JsonValue('show_up')
  showUp,
  @JsonValue('first_game')
  firstGame,
  @JsonValue('rate_game')
  rateGame,
  referee,
  win,
  goal,
  mvp,
  @JsonValue('pay_online')
  payOnline,
  invite,
  verified,
  @JsonValue('no_show')
  noShow,
  cancellation,
  admin,
}

/// One line of my wallet history (`public.wallet_ledger`, own rows only).
@freezed
abstract class LedgerEntry with _$LedgerEntry {
  const factory LedgerEntry({
    required RewardReason reason,
    required int xpDelta,
    required int coinsDelta,
    required DateTime createdAt,
  }) = _LedgerEntry;

  factory LedgerEntry.fromJson(Map<String, dynamic> json) =>
      _$LedgerEntryFromJson(json);
}
