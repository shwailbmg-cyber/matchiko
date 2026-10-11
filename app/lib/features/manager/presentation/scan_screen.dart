import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/features/manager/presentation/providers.dart';
import 'package:matchiko/shared/providers.dart';

/// `SC.mscan`: scan the booking QR after the cash → Guaranteed.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
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
    final async = ref.watch(venueTodayProvider);
    // Demo stand-in for the camera: the next booking waiting for payment.
    final next = async.value
        ?.where((g) => g.status == BookingStatus.confirmed)
        .firstOrNull;
    final g = _scanned;
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          async,
          onRetry: () => ref.invalidate(venueTodayProvider),
          data: (_) => ListView(
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
                    color: const Color(0xFF05040D),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: MkColors.primary, width: 3),
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
                  onPressed: next == null
                      ? null
                      : () => setState(() {
                          _scanned = next;
                          _cash = false;
                        }),
                  icon: const Icon(Icons.qr_code_2),
                  label: Text(next == null ? l.allDone : l.simulate),
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
                ),
            ],
          ),
        ),
      ),
    );
  }
}
