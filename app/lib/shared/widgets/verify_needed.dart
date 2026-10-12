import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/qr_payload.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/ticket.dart';

/// Sheet shown when an unverified player tries to book.
Future<void> showVerifyNeeded(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🪪', style: TextStyle(fontSize: 52)),
            const SizedBox(height: 8),
            Text(
              l.verifyNeeded,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              l.verifyNeededSub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MkColors.sub, height: 1.5),
            ),
            const SizedBox(height: 16),
            MyQrCard(label: l.myVerifyCode),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(l.done),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Sheet with the player's QR, scanned by the manager at check-in.
Future<void> showMyQr(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l.myQrSub,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MkColors.sub, height: 1.5),
          ),
          const SizedBox(height: 16),
          MyQrCard(label: l.myQr),
        ],
      ),
    ),
  );
}

/// The signed-in player's QR ([PlayerQr]) on a white card.
class MyQrCard extends ConsumerWidget {
  const MyQrCard({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final handle = ref.watch(meProvider).value?.handle;
    if (handle == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MkColors.text,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          QrCode('${PlayerQr(handle)}', size: 150),
          const SizedBox(height: 6),
          Text(
            '$label · @$handle',
            style: const TextStyle(
              color: MkColors.ink,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
