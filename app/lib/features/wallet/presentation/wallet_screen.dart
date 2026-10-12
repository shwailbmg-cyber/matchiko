import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/ledger_entry.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/badges.dart';

typedef _WalletData = ({Profile me, List<LedgerEntry> history});

final _walletProvider = FutureProvider.autoDispose<_WalletData>((ref) async {
  final repo = watchGames(ref);
  final r = await Future.wait([repo.me(), repo.walletHistory()]);
  return (me: r[0] as Profile, history: r[1] as List<LedgerEntry>);
});

/// `SC.wallet`: coins and XP, store (soon), how to earn, history.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.wallet)),
      body: AsyncView(
        ref.watch(_walletProvider),
        onRetry: () => ref.invalidate(_walletProvider),
        data: (w) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            _Balances(w.me),
            const SizedBox(height: 10),
            Text(l.xpSub, style: const TextStyle(color: MkColors.sub)),
            MkLabel(l.activity),
            if (w.history.isEmpty)
              Text(l.noActivity, style: const TextStyle(color: MkColors.sub))
            else
              MkCard(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [for (final e in w.history.take(20)) _Line(e)],
                ),
              ),
            Row(
              children: [
                MkLabel(l.store),
                const SizedBox(width: 8),
                MkTag(l.soon, color: MkColors.sand),
              ],
            ),
            const _Store(),
            MkLabel(l.earn),
            const _Earn(),
            const SizedBox(height: 16),
            MkCard(
              borderColor: MkColors.red.withValues(alpha: .4),
              child: Text(
                '⚠️ ${l.noshowRule}',
                style: const TextStyle(color: MkColors.sub, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Balances extends StatelessWidget {
  const _Balances(this.me);

  final Profile me;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    TextStyle big(Color c) => TextStyle(
      fontFamily: MkFonts.display,
      fontSize: 34,
      fontWeight: FontWeight.w800,
      color: c,
      height: 1.1,
    );
    return Row(
      children: [
        Expanded(
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(MkRadius.card),
              gradient: const LinearGradient(
                colors: [MkColors.heroViolet, MkColors.heroDeep],
              ),
            ),
            child: Zellij(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.coins, style: const TextStyle(color: MkColors.tint)),
                    FittedBox(
                      child: Text(
                        '🪙 ${money(me.coins)}',
                        style: big(MkColors.text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: MkCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.xp, style: const TextStyle(color: MkColors.sub)),
                FittedBox(child: Text(money(me.xp), style: big(MkColors.sand))),
                RankBadge(me.rank),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line(this.e);

  final LedgerEntry e;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    String signed(int v) => v > 0 ? '+$v' : '$v';
    final color = e.coinsDelta < 0 || e.xpDelta < 0
        ? MkColors.red
        : MkColors.primary;
    return ListTile(
      dense: true,
      title: Text(
        reasonLabel(l, e.reason),
        style: const TextStyle(fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        dayLabel(context, e.createdAt),
        style: const TextStyle(color: MkColors.sub),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (e.coinsDelta != 0)
            Text(
              '${signed(e.coinsDelta)} 🪙',
              style: TextStyle(color: color, fontWeight: FontWeight.w800),
            ),
          if (e.xpDelta != 0)
            Text(
              '${signed(e.xpDelta)} XP',
              style: const TextStyle(color: MkColors.sub, fontSize: 12),
            ),
        ],
      ),
    );
  }
}

String reasonLabel(AppLocalizations l, RewardReason r) => switch (r) {
  RewardReason.showUp => l.rShowUp,
  RewardReason.firstGame => l.rFirstGame,
  RewardReason.rateGame => l.rRate,
  RewardReason.referee => l.rReferee,
  RewardReason.win => l.rWin,
  RewardReason.goal => l.rGoal,
  RewardReason.mvp => l.rMvp,
  RewardReason.payOnline => l.rPayOnline,
  RewardReason.invite => l.rInvite,
  RewardReason.verified => l.rVerified,
  RewardReason.noShow => l.rNoShow,
  RewardReason.cancellation => l.rCancel,
  RewardReason.admin => l.rAdmin,
};

class _Store extends StatelessWidget {
  const _Store();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      ('🏟️', l.iDisc, 500),
      ('🎟️', l.iTicket, 800),
      ('👕', l.iJersey, 2500),
      ('🤝', l.iComm, 300),
      ('🖼️', l.iFrame, 150),
      ('🟨', l.iRef, 400),
    ];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: .8,
      children: [
        for (final (emoji, name, price) in items)
          MkCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 28)),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '🪙 ${money(price)}',
                  style: const TextStyle(color: MkColors.sand, fontSize: 12),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Earn extends StatelessWidget {
  const _Earn();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    // Coin amounts from reward_rules (migration 20261009000400).
    final rows = [
      ('✅', l.eShow, 20),
      ('⭐', l.eReview, 10),
      ('🟨', l.eRef, 50),
      ('🏆', l.eMvp, 30),
      ('💳', l.eOnline, 15),
      ('🤝', l.eInvite, 100),
      ('🪪', l.eVerify, 200),
    ];
    return MkCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (final (emoji, label, coins) in rows)
            ListTile(
              dense: true,
              leading: Text(emoji, style: const TextStyle(fontSize: 20)),
              title: Text(
                label,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: Text(
                '+$coins 🪙',
                style: const TextStyle(
                  color: MkColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
