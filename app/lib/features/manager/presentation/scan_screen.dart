import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/features/manager/presentation/providers.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/providers.dart';

enum _Mode { booking, verify, checkIn }

/// `SC.mscan`: one scanner, three jobs: booking QR after the cash
/// (→ Guaranteed), a player's verification QR, and check-in on arrival.
/// The demo has no camera: "Simulate scan" picks the next code.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  _Mode _mode = _Mode.booking;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
          children: [
            Text(
              l.scanTitle,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            SegmentedButton<_Mode>(
              showSelectedIcon: false,
              segments: [
                ButtonSegment(value: _Mode.booking, label: Text(l.scanBooking)),
                ButtonSegment(value: _Mode.verify, label: Text(l.scanVerify)),
                ButtonSegment(value: _Mode.checkIn, label: Text(l.scanCheckIn)),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() => _mode = s.first),
            ),
            const SizedBox(height: 16),
            const _Viewfinder(),
            const SizedBox(height: 16),
            switch (_mode) {
              _Mode.booking => const _BookingScan(),
              _Mode.verify => const _VerifyScan(),
              _Mode.checkIn => const _CheckInScan(),
            },
          ],
        ),
      ),
    );
  }
}

class _Viewfinder extends StatelessWidget {
  const _Viewfinder();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(
        color: const Color(0xFF05040D),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: MkColors.primary, width: 3),
      ),
      child: const Icon(
        Icons.qr_code_scanner,
        size: 100,
        color: MkColors.line2,
      ),
    ),
  );
}

/// Booking QR: cash received → Guaranteed.
class _BookingScan extends ConsumerStatefulWidget {
  const _BookingScan();

  @override
  ConsumerState<_BookingScan> createState() => _BookingScanState();
}

class _BookingScanState extends ConsumerState<_BookingScan> {
  Game? _scanned;
  bool _cash = false;

  Future<void> _markGuaranteed() async {
    final g = _scanned;
    if (g == null || !_cash) return;
    await ref.read(gameRepositoryProvider).scanBooking(g.code);
    if (mounted) setState(() => _scanned = null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final next = ref
        .watch(venueTodayProvider)
        .value
        ?.where((g) => g.status == BookingStatus.confirmed)
        .firstOrNull;
    final g = _scanned;
    if (g == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.scanHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MkColors.sub),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: next == null
                ? null
                : () => setState(() {
                    _scanned = next;
                    _cash = false;
                  }),
            icon: const Icon(Icons.qr_code_2),
            label: Text(next == null ? l.allDone : l.simulate),
          ),
        ],
      );
    }
    final booker = g.players.firstWhere(
      (p) => p.isBooker,
      orElse: () => g.players.first,
    );
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '✓ ${l.scanned}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            '${booker.name} · ${hhmm(g.startsAt)} · ${money(g.pitch.priceDa)} ${l.da}',
            style: const TextStyle(color: MkColors.sub),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _cash,
            onChanged: (_) => setState(() => _cash = !_cash),
            title: Text('💵 ${l.cashReceived}'),
          ),
          FilledButton(
            onPressed: _cash ? _markGuaranteed : null,
            child: Text('🛡️ ${l.markGuar}'),
          ),
          TextButton(
            onPressed: () => setState(() => _scanned = null),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }
}

/// A player's verification QR: check the ID card in person, then verify.
class _VerifyScan extends ConsumerStatefulWidget {
  const _VerifyScan();

  @override
  ConsumerState<_VerifyScan> createState() => _VerifyScanState();
}

class _VerifyScanState extends ConsumerState<_VerifyScan> {
  Profile? _scanned;
  final _checks = <int>{};

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final next = ref.watch(verificationQueueProvider).value?.firstOrNull;
    final p = _scanned;
    if (p == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.scanVerifyHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MkColors.sub),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: next == null
                ? null
                : () => setState(() {
                    _scanned = next;
                    _checks.clear();
                  }),
            icon: const Icon(Icons.badge_outlined),
            label: Text(next == null ? l.allDone : l.simulate),
          ),
        ],
      );
    }
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              MkAvatar(p.initials, size: 44),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${p.name}\n@${p.handle}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          for (final (k, label) in [l.chkName, l.chkPhoto, l.chkAge].indexed)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              dense: true,
              value: _checks.contains(k),
              onChanged: (_) => setState(
                () => _checks.contains(k) ? _checks.remove(k) : _checks.add(k),
              ),
              title: Text(label),
            ),
          FilledButton(
            onPressed: _checks.length == 3
                ? () async {
                    await ref
                        .read(gameRepositoryProvider)
                        .verifyPlayer(p.handle);
                    if (mounted) setState(() => _scanned = null);
                  }
                : null,
            child: Text('✔ ${l.verify}'),
          ),
          TextButton(
            onPressed: () => setState(() => _scanned = null),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }
}

/// Check-in: scan each player's QR when they arrive.
class _CheckInScan extends ConsumerStatefulWidget {
  const _CheckInScan();

  @override
  ConsumerState<_CheckInScan> createState() => _CheckInScanState();
}

class _CheckInScanState extends ConsumerState<_CheckInScan> {
  String? _gameId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final games = (ref.watch(venueTodayProvider).value ?? const <Game>[])
        .where(
          (g) =>
              g.status == BookingStatus.guaranteed ||
              g.status == BookingStatus.confirmed,
        )
        .toList();
    if (games.isEmpty) {
      return Text(
        l.noGames,
        textAlign: TextAlign.center,
        style: const TextStyle(color: MkColors.sub),
      );
    }
    final g = games.firstWhere(
      (x) => x.id == _gameId,
      orElse: () => games.first,
    );
    final players = g.players.where((p) => !p.guest).toList();
    final arrived = players.where((p) => p.attended).length;
    final next = players.where((p) => !p.attended).firstOrNull;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DropdownButton<String>(
          value: g.id,
          isExpanded: true,
          items: [
            for (final x in games)
              DropdownMenuItem(
                value: x.id,
                child: Text('${hhmm(x.startsAt)} · ${x.perSide}v${x.perSide}'),
              ),
          ],
          onChanged: (v) => setState(() => _gameId = v),
        ),
        const SizedBox(height: 8),
        Text(
          l.arrivedCount('$arrived', '${players.length}'),
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: next == null
              ? null
              : () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ref
                      .read(gameRepositoryProvider)
                      .checkInPlayer(g.id, next.handle);
                  messenger.showSnackBar(
                    SnackBar(content: Text(l.arrived(next.name))),
                  );
                },
          icon: const Icon(Icons.how_to_reg),
          label: Text(next == null ? l.allDone : l.simulate),
        ),
      ],
    );
  }
}
