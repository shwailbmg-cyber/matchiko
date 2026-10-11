import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/game.dart';
import '../../../../domain/models/pitch.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../routing/routes.dart';
import '../../../core/format.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/theme/mk_theme.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/mk_widgets.dart';
import '../../../core/widgets/zellij.dart';
import '../view_models/home_view_model.dart';

/// `SC.home` in the prototype: hero with the live counter, games missing
/// players, pitches near you.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          loading: vm.loading,
          error: vm.error,
          onRetry: vm.load,
          builder: (_) => ListView(
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
                      child: MkAvatar(vm.me?.initials ?? '', size: 40),
                    ),
                  ],
                ),
              ),
              _Hero(live: vm.live),
              MkSection(l.openGames),
              SizedBox(
                height: 196,
                child: vm.openGames.isEmpty
                    ? Center(
                        child: Text(
                          l.allDone,
                          style: const TextStyle(color: MkColors.sub),
                        ),
                      )
                    : ListView.separated(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: vm.openGames.length,
                        separatorBuilder: (_, _) => const SizedBox(width: 12),
                        itemBuilder: (_, i) => _OpenGameCard(vm.openGames[i]),
                      ),
              ),
              MkSection(l.nearby),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  onChanged: vm.search,
                  decoration: InputDecoration(
                    hintText: l.searchPh,
                    prefixIcon: const Icon(Icons.search, color: MkColors.faint),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              for (final p in vm.pitches)
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
        border: Border.all(color: MkColors.lime.withValues(alpha: .28)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1F7C47), Color(0xFF155733), Color(0xFF0E3D23)],
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
                        color: MkColors.lime,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l.live(live.toString()),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFBFF3D4),
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
                style: const TextStyle(color: Color(0xFFCDE7D6), height: 1.5),
              ),
              const SizedBox(height: 20),
              FilledButton.icon(
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
                            ? MkColors.lime
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
class PitchRow extends StatelessWidget {
  const PitchRow(this.pitch, {super.key});

  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return MkCard(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 16, 10),
      onTap: () => context.push(Routes.pitch(pitch.id)),
      child: Row(
        children: [
          const SizedBox(width: 76, child: PitchTurf()),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pitch.name(lang),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${pitch.district} · ${pitch.km} ${l.km}',
                  style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: MkColors.sand),
                    Text(
                      ' ${pitch.rating}  ',
                      style: const TextStyle(
                        color: MkColors.sand,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    MkTag('≤ ${pitch.maxPerSide}v${pitch.maxPerSide}'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                money(pitch.priceDa),
                style: const TextStyle(
                  fontFamily: MkFonts.display,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              Text(
                '${l.da}${l.perHour}',
                style: const TextStyle(color: MkColors.sub, fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
