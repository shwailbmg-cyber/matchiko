import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../l10n/gen/app_localizations.dart';
import '../../../core/theme/mk_colors.dart';
import '../../auth/view_models/session_view_model.dart';
import '../view_models/settings_view_model.dart';

/// Language picker + log out (`SC.settings` in the prototype). Notification
/// toggles come with the notifications feature.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final settings = context.watch<SettingsViewModel>();
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              const Icon(Icons.language, size: 15, color: MkColors.sub),
              const SizedBox(width: 8),
              Text(
                l.language.toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: MkColors.sub,
                  letterSpacing: .9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Card(
            child: RadioGroup<String>(
              groupValue: settings.locale.languageCode,
              onChanged: (v) => settings.setLanguage(v!),
              child: Column(
                children: [
                  for (final (code, name) in [
                    ('en', 'English'),
                    ('fr', 'Français'),
                    ('ar', 'العربية'),
                  ])
                    RadioListTile<String>(
                      value: code,
                      title: Text(
                        name,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: MkColors.red,
              side: BorderSide(color: MkColors.red.withValues(alpha: .3)),
            ),
            onPressed: () => context.read<SessionViewModel>().signOut(),
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }
}
