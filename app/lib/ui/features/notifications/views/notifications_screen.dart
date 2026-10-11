import 'package:flutter/material.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/widgets/mk_widgets.dart';

/// Notifications center. Sample items in demo mode; the `notifications`
/// table feeds it with Supabase (M3).
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      ('?', MkColors.sand, l.nStillTitle, l.nStillBody),
      ('+', MkColors.primary, l.nSpotTitle, l.nSpotBody),
      ('✓', MkColors.blue, l.nConfTitle, l.nConfBody),
      ('★', MkColors.sand, l.nRateTitle, l.nRateBody),
    ];
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.notifs)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final (mark, color, title, body) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MkCard(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: .15),
                        borderRadius: BorderRadius.circular(11),
                      ),
                      child: Text(
                        mark,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            body,
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
              ),
            ),
        ],
      ),
    );
  }
}
