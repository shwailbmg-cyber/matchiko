import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/booking_status.dart';
import '../../../../domain/models/game.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../routing/routes.dart';
import '../../../core/format.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/theme/mk_theme.dart';
import '../../../core/widgets/mk_widgets.dart';
import '../../../core/widgets/ticket.dart';
import '../view_models/matches_view_model.dart';

/// `SC.matches`: upcoming games with status + QR, past games to rate.
class MatchesScreen extends StatelessWidget {
  const MatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<MatchesViewModel>();
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          loading: vm.loading,
          error: vm.error,
          onRetry: vm.load,
          builder: (_) {
            final list = vm.showPast ? vm.past : vm.upcoming;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.only(
                    start: 4,
                    bottom: 16,
                  ),
                  child: MkTitle(l.navMatches),
                ),
                SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: [
                    ButtonSegment(value: false, label: Text(l.upcoming)),
                    ButtonSegment(value: true, label: Text(l.past)),
                  ],
                  selected: {vm.showPast},
                  onSelectionChanged: (s) => vm.setTab(past: s.first),
                ),
                const SizedBox(height: 16),
                if (list.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 60),
                    child: Center(
                      child: Text(
                        l.noGames,
                        style: const TextStyle(color: MkColors.sub),
                      ),
                    ),
                  ),
                for (final g in list)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: vm.showPast
                        ? _PastCard(
                            g,
                            rated: vm.rated.contains(g.id),
                            onRate: () => _rate(context, vm, g),
                          )
                        : _UpcomingCard(g),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _rate(BuildContext context, MatchesViewModel vm, Game g) async {
    final l = AppLocalizations.of(context);
    var stars = 0;
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, set) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.rateTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(l.ratePitch, style: const TextStyle(color: MkColors.sub)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 1; i <= 5; i++)
                    IconButton(
                      iconSize: 36,
                      tooltip: '$i',
                      onPressed: () => set(() => stars = i),
                      icon: Icon(
                        Icons.star,
                        color: i <= stars ? MkColors.sand : MkColors.card2,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: stars == 0
                    ? null
                    : () => Navigator.of(ctx).pop(true),
                child: Text('${l.submit} · +10 🪙'),
              ),
            ],
          ),
        ),
      ),
    );
    if (ok ?? false) vm.rate(g.id);
  }
}

class _DateBlock extends StatelessWidget {
  const _DateBlock(this.t);

  final DateTime t;

  @override
  Widget build(BuildContext context) => Container(
    width: 56,
    height: 62,
    decoration: BoxDecoration(
      color: MkColors.card2,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          dayLabel(context, t).toUpperCase(),
          maxLines: 1,
          style: const TextStyle(
            fontSize: 10,
            color: MkColors.sub,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          '${t.day}',
          style: const TextStyle(
            fontFamily: MkFonts.display,
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard(this.g);

  final Game g;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return MkCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(Routes.game(g.id)),
      child: Column(
        children: [
          Row(
            children: [
              _DateBlock(g.startsAt),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      g.pitch.name(lang),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${hhmm(g.startsAt)} · ${g.perSide}v${g.perSide}'
                      '${g.iAmBooker ? ' · ${l.booker}' : ''}',
                      style: const TextStyle(
                        color: MkColors.sub,
                        fontSize: 12.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StatusTag(g.status),
                  ],
                ),
              ),
              if (g.status != BookingStatus.requested)
                IconButton.outlined(
                  tooltip: l.showQr,
                  color: MkColors.lime,
                  onPressed: () => showTicket(context, g),
                  icon: const Icon(Icons.qr_code_2),
                ),
            ],
          ),
          const Divider(color: MkColors.line, height: 24),
          StatusLadder(g.status),
        ],
      ),
    );
  }
}

class _PastCard extends StatelessWidget {
  const _PastCard(this.g, {required this.rated, required this.onRate});

  final Game g;
  final bool rated;
  final VoidCallback onRate;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return MkCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          _DateBlock(g.startsAt),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  g.pitch.name(lang),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${g.perSide}v${g.perSide}',
                  style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                ),
              ],
            ),
          ),
          if (rated)
            Text('✓ ${l.rated}', style: const TextStyle(color: MkColors.sub))
          else
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 36)),
              onPressed: onRate,
              child: Text(l.rate),
            ),
        ],
      ),
    );
  }
}
