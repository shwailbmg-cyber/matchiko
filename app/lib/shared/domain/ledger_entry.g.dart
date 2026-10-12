// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ledger_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LedgerEntry _$LedgerEntryFromJson(Map<String, dynamic> json) => _LedgerEntry(
  reason: $enumDecode(_$RewardReasonEnumMap, json['reason']),
  xpDelta: (json['xp_delta'] as num).toInt(),
  coinsDelta: (json['coins_delta'] as num).toInt(),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$LedgerEntryToJson(_LedgerEntry instance) =>
    <String, dynamic>{
      'reason': _$RewardReasonEnumMap[instance.reason]!,
      'xp_delta': instance.xpDelta,
      'coins_delta': instance.coinsDelta,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$RewardReasonEnumMap = {
  RewardReason.showUp: 'show_up',
  RewardReason.firstGame: 'first_game',
  RewardReason.rateGame: 'rate_game',
  RewardReason.referee: 'referee',
  RewardReason.win: 'win',
  RewardReason.goal: 'goal',
  RewardReason.mvp: 'mvp',
  RewardReason.payOnline: 'pay_online',
  RewardReason.invite: 'invite',
  RewardReason.verified: 'verified',
  RewardReason.noShow: 'no_show',
  RewardReason.cancellation: 'cancellation',
  RewardReason.admin: 'admin',
};
