import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/position.dart';
import '../../../../domain/models/rank.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../routing/routes.dart';
import '../../../core/format.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/theme/mk_theme.dart';
import '../../../core/widgets/mk_widgets.dart';
import '../../../core/widgets/zellij.dart';
import '../../pitch/views/pitch_screen.dart' show showVerifyNeeded;
import '../view_models/profile_view_model.dart';

/// `SC.profile`: identity card, rank progress, XP and coins, reliability.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          loading: vm.loading,
          error: vm.error,
          onRetry: vm.load,
          builder: (_) {
            final me = vm.me!;
            final rank = me.rank;
            final next = rank.next;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
              children: [
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      child: MkTitle(l.navProfile),
                    ),
                    const Spacer(),
                    IconButton(
                      tooltip: l.settings,
                      onPressed: () => context.push(Routes.settings),
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: MkColors.sub,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: MkColors.lime.withValues(alpha: .22),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF17583A), Color(0xFF0D2819)],
                    ),
                  ),
                  child: Zellij(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MkAvatar(me.initials, size: 72),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      me.name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 20,
                                      ),
                                    ),
                                    Text(
                                      '@${me.handle}',
                                      style: const TextStyle(
                                        color: Color(0xFFCDE7D6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        RankBadge(rank),
                                        if (me.verified)
                                          const VerifiedBadge()
                                        else
                                          InkWell(
                                            onTap: () =>
                                                showVerifyNeeded(context),
                                            child: MkTag(
                                              '🪪 ${l.getVerified}',
                                              color: MkColors.sand,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final p in me.positions) PositionBadge(p),
                              if (me.isReferee)
                                const PositionBadge(Position.ref),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _Tok(l.xp, money(me.xp), MkColors.sand),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _Tok(
                                  l.coins,
                                  '🪙 ${money(me.coins)}',
                                  MkColors.lime,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _Stat('${me.played}', l.played)),
                    const SizedBox(width: 8),
                    Expanded(child: _Stat('${me.wins}', l.wins)),
                    const SizedBox(width: 8),
                    Expanded(child: _Stat('${me.reliability}%', l.reliability)),
                  ],
                ),
                const SizedBox(height: 12),
                MkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            rank.emoji,
                            style: const TextStyle(fontSize: 36),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l.rank,
                                style: const TextStyle(
                                  color: MkColors.sub,
                                  fontSize: 12.5,
                                ),
                              ),
                              RankBadge(rank),
                            ],
                          ),
                          const Spacer(),
                          if (next != null)
                            Text(
                              '${money(me.xp)} / ${money(next.minXp)}',
                              style: const TextStyle(
                                fontFamily: MkFonts.display,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: Rank.progress(me.xp),
                          minHeight: 8,
                          backgroundColor: MkColors.card2,
                          color: MkColors.sand,
                        ),
                      ),
                      if (next != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          l.toNext(
                            money(next.minXp - me.xp),
                            rankName(l, next),
                          ),
                          style: const TextStyle(
                            color: MkColors.sub,
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                MkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            l.reliability,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const Spacer(),
                          Text(
                            '${me.reliability}%',
                            style: const TextStyle(
                              fontFamily: MkFonts.display,
                              fontWeight: FontWeight.w700,
                              fontSize: 18,
                              color: MkColors.lime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: me.reliability / 100,
                          minHeight: 8,
                          backgroundColor: MkColors.card2,
                          color: MkColors.lime,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '⚠️ ${l.noshowRule}',
                        style: const TextStyle(
                          color: MkColors.sand,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Tok extends StatelessWidget {
  const _Tok(this.label, this.value, this.color);

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    decoration: BoxDecoration(
      color: MkColors.ink.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFFB5D6C1),
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontFamily: MkFonts.display,
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => MkCard(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: MkFonts.display,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: MkColors.sub),
        ),
      ],
    ),
  );
}
