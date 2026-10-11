import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/booking_status.dart';
import '../../../../domain/models/game.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../core/format.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/theme/mk_theme.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/mk_widgets.dart';
import '../view_models/manager_view_models.dart';

/// `SC.mtoday`: today's timeline, requests to confirm by phone.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TodayViewModel>();
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          loading: vm.loading,
          error: vm.error,
          onRetry: vm.load,
          builder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              Row(
                children: [
                  const MkLogo(),
                  const Spacer(),
                  MkTag('🏟️ ${l.manager}', color: MkColors.sand),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                vm.games.isEmpty ? '' : vm.games.first.pitch.name(lang),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                dayLabel(context, DateTime.now()),
                style: const TextStyle(color: MkColors.sub),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _Stat(
                      '${vm.games.length}',
                      l.bookings,
                      MkColors.text,
                    ),
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
                      MkColors.lime,
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
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
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
          ),
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard(this.g, this.vm);

  final Game g;
  final TodayViewModel vm;

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

/// `SC.mscan`: scan the booking QR after the cash → Guaranteed.
class ScanScreen extends StatelessWidget {
  const ScanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ScanViewModel>();
    final l = AppLocalizations.of(context);
    final g = vm.scanned;
    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          loading: vm.loading,
          error: vm.error,
          onRetry: vm.load,
          builder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              Text(
                l.scanTitle,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    color: const Color(0xFF020604),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: MkColors.lime, width: 3),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner,
                    size: 120,
                    color: MkColors.line2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                l.scanHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MkColors.sub),
              ),
              const SizedBox(height: 20),
              if (g == null)
                FilledButton.icon(
                  onPressed: vm.nextToScan == null ? null : vm.simulateScan,
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(vm.nextToScan == null ? l.allDone : l.simulate),
                )
              else
                MkCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '✓ ${l.scanned}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${g.players.firstWhere((p) => p.isBooker, orElse: () => g.players.first).name} · '
                        '${hhmm(g.startsAt)} · ${money(g.pitch.priceDa)} ${l.da}',
                        style: const TextStyle(color: MkColors.sub),
                      ),
                      CheckboxListTile(
                        contentPadding: EdgeInsets.zero,
                        value: vm.cashReceived,
                        onChanged: (_) => vm.toggleCash(),
                        title: Text('💵 ${l.cashReceived}'),
                      ),
                      FilledButton(
                        onPressed: vm.cashReceived ? vm.markGuaranteed : null,
                        child: Text('🛡️ ${l.markGuar}'),
                      ),
                      TextButton(onPressed: vm.close, child: Text(l.cancel)),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `SC.mplayers`: in-person ID verification queue.
class PlayersScreen extends StatelessWidget {
  const PlayersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayersViewModel>();
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncBody(
          loading: vm.loading,
          error: vm.error,
          onRetry: vm.load,
          builder: (_) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              MkTitle(l.mgPlayers),
              MkLabel('${l.verifyQ} · ${vm.queue.length}'),
              if (vm.queue.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      '✅ ${l.allDone}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              for (final (i, p) in vm.queue.indexed)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: MkCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            MkAvatar(p.initials, size: 48, seed: i + 3),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    '@${p.handle} · ${l.gamesN(p.played.toString())}',
                                    style: const TextStyle(
                                      color: MkColors.sub,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        for (final (k, label) in [
                          l.chkName,
                          l.chkPhoto,
                          l.chkAge,
                        ].indexed)
                          CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                            value: vm.checked(p.handle, k),
                            onChanged: (_) => vm.toggle(p.handle, k),
                            title: Text(label),
                          ),
                        FilledButton(
                          onPressed: vm.ready(p.handle)
                              ? () => vm.verify(p.handle)
                              : null,
                          child: Text('✔ ${l.verify}'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
