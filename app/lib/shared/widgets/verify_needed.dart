import 'package:flutter/material.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';

/// Sheet shown when an unverified player tries to book.
Future<void> showVerifyNeeded(BuildContext context) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
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
          const SizedBox(height: 20),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l.done),
          ),
        ],
      ),
    ),
  );
}
