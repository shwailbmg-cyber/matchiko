import 'package:flutter/material.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';

/// Plain-language summary of what the app stores and who sees it.
/// The full terms and privacy policy come with the legal review.
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      ('👤', l.pvWhatTitle, l.pvWhatBody),
      ('📞', l.pvPhoneTitle, l.pvPhoneBody),
      ('🪪', l.pvIdTitle, l.pvIdBody),
      ('📍', l.pvPlaceTitle, l.pvPlaceBody),
      ('🗑️', l.pvDeleteTitle, l.pvDeleteBody),
    ];
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.privacyTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          for (final (emoji, title, body) in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MkCard(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            body,
                            style: const TextStyle(
                              color: MkColors.sub,
                              height: 1.5,
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
