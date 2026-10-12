import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/features/player/presentation/report_sheet.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/wilaya.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/shared/widgets/friend_button.dart';

final _playerProvider = FutureProvider.autoDispose.family<Player, String>(
  (ref, handle) => watchGames(ref).player(handle),
);

/// Another player's public profile: rank, positions, games, friend button.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen(this.handle, {super.key, this.gameId});

  final String handle;

  /// Set when opened from a game: allows a no-show report.
  final String? gameId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg),
      body: AsyncView(
        ref.watch(_playerProvider(handle)),
        onRetry: () => ref.invalidate(_playerProvider(handle)),
        data: (p) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
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
                    children: [
                      MkAvatar(
                        p.initials,
                        size: 84,
                        seed: p.name.length,
                        photo: p.avatar,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        p.name,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        [
                          '@${p.handle}',
                          ?Wilaya.byId(p.wilayaId)?.name(lang),
                        ].join(' · '),
                        style: const TextStyle(color: MkColors.tint),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          RankBadge(p.rank),
                          if (p.verified) const VerifiedBadge(),
                          for (final pos in p.positions) PositionBadge(pos),
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
                Expanded(child: _Num('${p.played}', l.played)),
                const SizedBox(width: 8),
                Expanded(child: _Num('${p.xp}', l.xp)),
                const SizedBox(width: 8),
                Expanded(child: _Num('${p.reliability}%', l.reliability)),
              ],
            ),
            const SizedBox(height: 16),
            FriendButton(p),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: MkColors.red),
                  onPressed: () => showReportSheet(
                    context,
                    handle: p.handle,
                    gameId: gameId,
                  ),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: Text(l.report),
                ),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: MkColors.sub),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    await ref.read(gameRepositoryProvider).block(p.handle);
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.blockedDone)),
                    );
                  },
                  icon: const Icon(Icons.block, size: 18),
                  label: Text(l.block),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Num extends StatelessWidget {
  const _Num(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => MkCard(
    child: Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontFamily: MkFonts.display,
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: const TextStyle(color: MkColors.sub, fontSize: 12)),
      ],
    ),
  );
}
