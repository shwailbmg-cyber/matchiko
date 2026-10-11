import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/router/routes.dart';

import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/logo_mark.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/features/manager/presentation/providers.dart';
import 'package:matchiko/shared/providers.dart';

/// `SC.mtoday`: today's timeline, requests to confirm by phone.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          ref.watch(venueTodayProvider),
          onRetry: () => ref.invalidate(venueTodayProvider),
          data: (games) => _today(context, _TodayVm(games, ref)),
        ),
      ),
    );
  }

  Widget _today(BuildContext context, _TodayVm vm) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
      children: [
        Row(
          children: [
            const MkLogo(),
            Expanded(
              child: Align(
                alignment: AlignmentDirectional.centerEnd,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: MkTag('🏟️ ${l.manager}', color: MkColors.sand),
                ),
              ),
            ),
            IconButton(
              tooltip: l.myVenue,
              onPressed: () => context.push(Routes.mVenue),
              icon: const Icon(Icons.storefront_outlined, color: MkColors.sub),
            ),
            IconButton(
              tooltip: l.settings,
              onPressed: () => context.push(Routes.settings),
              icon: const Icon(Icons.settings_outlined, color: MkColors.sub),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          vm.games.isEmpty ? '' : vm.games.first.pitch.name(lang),
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        Text(
          dayLabel(context, DateTime.now()),
          style: const TextStyle(color: MkColors.sub),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _Stat('${vm.games.length}', l.bookings, MkColors.text),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Stat(
                '${vm.count(BookingStatus.requested)}',
                l.toConfirm,
                MkColors.sand,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Stat(
                '${vm.count(BookingStatus.guaranteed)}',
                l.stGuaranteed,
                MkColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        for (var h = 17; h <= 23; h++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 50,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      '${h.toString().padLeft(2, '0')}:00',
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        fontFamily: MkFonts.display,
                        fontSize: 17,
                        color: MkColors.sub,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: vm.at(h) == null
                      ? Container(
                          height: 44,
                          alignment: AlignmentDirectional.centerStart,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            border: Border.all(color: MkColors.line2),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            l.freeSlot,
                            style: const TextStyle(
                              color: MkColors.faint,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        )
                      : _BookingCard(vm.at(h)!, vm),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard(this.g, this.vm);

  final Game g;
  final _TodayVm vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final booker = g.players.firstWhere(
      (p) => p.isBooker,
      orElse: () => g.players.first,
    );
    final color = statusLabel(l, g.status).$2;
    // Rounded card with a status stripe: a radius needs a uniform border, so
    // the stripe is an inner border clipped by the card.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: MkColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: MkColors.line),
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: BorderDirectional(start: BorderSide(color: color, width: 3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                MkAvatar(booker.initials, size: 30, seed: booker.name.length),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booker.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                StatusTag(g.status),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${g.perSide}v${g.perSide} · ${money(g.pitch.priceDa)} ${l.da}',
              style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
            ),
            if (g.status == BookingStatus.requested) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('📞 ${booker.name}')),
                    ),
                    child: Text('📞 ${l.call}'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () => vm.confirm(g.id),
                      child: Text(l.confirm),
                    ),
                  ),
                ],
              ),
            ] else if (g.status == BookingStatus.confirmed) ...[
              const SizedBox(height: 10),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () => vm.noShow(g.id),
                  child: Text(l.noshow),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => MkCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: TextStyle(
            fontFamily: MkFonts.display,
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: color,
            height: 1,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: MkColors.sub),
        ),
      ],
    ),
  );
}

/// Today's list with the manager's actions.
class _TodayVm {
  _TodayVm(this.games, this._ref);

  final List<Game> games;
  final WidgetRef _ref;

  int count(BookingStatus s) => games.where((g) => g.status == s).length;

  Game? at(int hour) => games.where((g) => g.startsAt.hour == hour).firstOrNull;

  Future<void> confirm(String id) =>
      _ref.read(gameRepositoryProvider).confirmBooking(id);
  Future<void> noShow(String id) =>
      _ref.read(gameRepositoryProvider).markNoShow(id);
}
