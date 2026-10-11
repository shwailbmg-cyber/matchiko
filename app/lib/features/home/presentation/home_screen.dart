import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/logo_mark.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/features/home/presentation/providers.dart';
import 'package:matchiko/shared/widgets/pitch_row.dart';

/// `SC.home` in the prototype: hero with the live counter, games missing
/// players, pitches near you.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pitches = ref.watch(pitchesProvider(_query)).value ?? const [];
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          ref.watch(homeProvider),
          onRetry: () => ref.invalidate(homeProvider),
          data: (home) => ListView(
            padding: const EdgeInsets.only(bottom: 28),
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20, 6, 20, 16),
                child: Row(
                  children: [
                    const MkLogo(),
                    const Spacer(),
                    IconButton(
                      tooltip: l.notifs,
                      onPressed: () => context.push(Routes.notifications),
                      icon: const Icon(
                        Icons.notifications_none,
                        color: MkColors.sub,
                      ),
                    ),
                    const SizedBox(width: 4),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => context.go(Routes.profile),
                      child: MkAvatar(home.me.initials, size: 40),
                    ),
                  ],
                ),
              ),
              _Hero(live: home.live),
              MkSection(l.openGames),
              SizedBox(
                height: 196,
                child: home.openGames.isEmpty
                    ? Center(
                        child: Text(
                          l.allDone,
                          style: const TextStyle(color: MkColors.sub),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: home.openGames.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _OpenGameCard(home.openGames[i]),
                      ),
              ),
              MkSection(
                l.nearby,
                trailing: TextButton(
                  onPressed: () => context.push(Routes.pitches),
                  child: Text(l.seeAll),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: (q) => setState(() => _query = q),
                  decoration: InputDecoration(
                    hintText: l.searchPh,
                    prefixIcon: const Icon(Icons.search, color: MkColors.faint),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final p in pitches)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: PitchRow(p),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.live});

  final int live;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: MkColors.primary.withValues(alpha: .28)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            MkColors.heroBlue,
            MkColors.heroViolet,
            MkColors.heroMagenta,
          ],
        ),
      ),
      child: Zellij(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsetsDirectional.fromSTEB(10, 5, 12, 5),
                decoration: BoxDecoration(
                  color: MkColors.ink.withValues(alpha: .5),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: MkColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l.live(live.toString()),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: MkColors.tint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l.homeTitle.toUpperCase(),
                style: mkDisplay(context, size: 44),
              ),
              const SizedBox(height: 10),
              Text(
                l.playSub,
                style: const TextStyle(color: MkColors.tint, height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: MkColors.ink,
                ),
                onPressed: () => context.go(Routes.play),
                icon: const Icon(Icons.bolt),
                label: Text(l.playNow),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OpenGameCard extends StatelessWidget {
  const _OpenGameCard(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return SizedBox(
      width: 262,
      child: MkCard(
        onTap: () => context.push(Routes.game(game.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MkTag('${game.perSide}v${game.perSide}'),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${dayLabel(context, game.startsAt)} · ${hhmm(game.startsAt)}',
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              game.pitch.name(lang),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            Text(
              '${game.pitch.km} ${l.km} · ${l.each(money(game.share.perPlayer))}',
              style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                for (var i = 0; i < game.capacity; i++)
                  Expanded(
                    child: Container(
                      height: 6,
                      margin: const EdgeInsetsDirectional.only(end: 3),
                      decoration: BoxDecoration(
                        color: i < game.players.length
                            ? MkColors.primary
                            : MkColors.card2,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Text(
                    l.spots(game.spotsLeft.toString()),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: MkColors.sand,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 36,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 36),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    onPressed: () => context.push(Routes.game(game.id)),
                    child: Text(l.join),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Pitch row used on home and search: turf thumb, name, distance, rating,
/// size, price per hour.
