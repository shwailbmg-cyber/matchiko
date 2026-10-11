import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/theme/mk_colors.dart';

/// Language picker + log out (`SC.settings` in the prototype). Notification
/// toggles come with the notifications feature.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
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
              groupValue: locale.languageCode,
              onChanged: (v) =>
                  ref.read(localeProvider.notifier).setLanguage(v!),
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
          if (ref.watch(gameRepositoryProvider)
              case final DemoGameRepository demo)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Card(
                child: SwitchListTile(
                  title: Text('${l.demo} · ${l.demoVerified}'),
                  subtitle: Text(l.demoVerifiedSub),
                  value: ref.watch(meProvider).value?.verified ?? true,
                  onChanged: demo.setVerified,
                ),
              ),
            ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: MkColors.red,
              side: BorderSide(color: MkColors.red.withValues(alpha: .3)),
            ),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            child: Text(l.logout),
          ),
        ],
      ),
    );
  }
}
