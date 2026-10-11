import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/rank.dart';
import 'package:matchiko/shared/domain/wilaya.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/verify_needed.dart';

/// `SC.profile`: identity card, rank progress, XP and coins, reliability.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          ref.watch(meProvider),
          onRetry: () => ref.invalidate(meProvider),
          data: (me) {
            final rank = me.rank;
            final next = rank.next;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 4),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: AlignmentDirectional.centerStart,
                          child: MkTitle(l.navProfile),
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: l.editProfile,
                      onPressed: () => context.push(Routes.editProfile),
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: MkColors.sub,
                      ),
                    ),
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
                      color: MkColors.primary.withValues(alpha: .22),
                    ),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [MkColors.heroViolet, MkColors.heroDeep],
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
                                      [
                                        '@${me.handle}',
                                        ?Wilaya.byId(me.wilayaId)?.name(
                                          Localizations.localeOf(context)
                                              .languageCode,
                                        ),
                                      ].join(' · '),
                                      style: const TextStyle(
                                        color: MkColors.tint,
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
                                child: InkWell(
                                  onTap: () => context.push(Routes.wallet),
                                  child: _Tok(
                                    l.xp,
                                    money(me.xp),
                                    MkColors.sand,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: InkWell(
                                  onTap: () => context.push(Routes.wallet),
                                  child: _Tok(
                                    l.coins,
                                    '🪙 ${money(me.coins)}',
                                    MkColors.primary,
                                  ),
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
                            Flexible(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '${money(me.xp)} / ${money(next.minXp)}',
                                  style: const TextStyle(
                                    fontFamily: MkFonts.display,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
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
                              color: MkColors.primary,
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
                          color: MkColors.primary,
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
                const SizedBox(height: 12),
                MkCard(
                  onTap: () => context.push(Routes.teams),
                  child: Row(
                    children: [
                      const Text('🛡️', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l.teams,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: MkColors.sub),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                MkCard(
                  onTap: () => context.push(Routes.friends),
                  child: Row(
                    children: [
                      const Text('🤝', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l.friendsTitle,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              l.inviteSub,
                              style: const TextStyle(
                                color: MkColors.sub,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: MkColors.sub),
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
            color: MkColors.tint2,
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
