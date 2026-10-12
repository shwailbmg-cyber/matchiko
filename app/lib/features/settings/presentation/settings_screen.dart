import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/push/push.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/my_settings.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/user_role.dart';
import 'package:matchiko/shared/providers.dart';

final _settingsProvider = FutureProvider.autoDispose<MySettings>(
  (ref) => watchGames(ref).mySettings(),
);

final _blockedProvider = FutureProvider.autoDispose<List<Player>>(
  (ref) => watchGames(ref).blockedPlayers(),
);

/// Settings: language, notifications, privacy, blocked players, help,
/// privacy summary, log out, delete my account.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final locale = ref.watch(localeProvider);
    final repo = ref.watch(gameRepositoryProvider);
    final isPlayer = ref.watch(sessionProvider).value?.role != UserRole.manager;
    final s = ref.watch(_settingsProvider).value;
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.settings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          _Group(Icons.language, l.language),
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
          if (isPlayer && s != null) ...[
            _Group(Icons.notifications_none, l.notifs),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text(l.alerts),
                    subtitle: Text(l.alertsSub),
                    value: s.notifyNearby,
                    onChanged: (v) =>
                        repo.updateSettings(s.copyWith(notifyNearby: v)),
                  ),
                  SwitchListTile(
                    title: Text(l.reminders),
                    subtitle: Text(l.remindersSub),
                    value: s.notifyReminders,
                    onChanged: (v) =>
                        repo.updateSettings(s.copyWith(notifyReminders: v)),
                  ),
                ],
              ),
            ),
            _Group(Icons.lock_outline, l.privacy),
            Card(
              child: RadioGroup<GamesVisibility>(
                groupValue: s.visibility,
                onChanged: (v) =>
                    repo.updateSettings(s.copyWith(visibility: v!)),
                child: Column(
                  children: [
                    ListTile(
                      dense: true,
                      title: Text(
                        l.whoSeesGames,
                        style: const TextStyle(color: MkColors.sub),
                      ),
                    ),
                    for (final (v, label) in [
                      (GamesVisibility.everyone, l.visEveryone),
                      (GamesVisibility.friends, l.visFriends),
                      (GamesVisibility.nobody, l.visNobody),
                    ])
                      RadioListTile<GamesVisibility>(
                        value: v,
                        title: Text(label),
                        controlAffinity: ListTileControlAffinity.trailing,
                      ),
                    ListTile(
                      title: Text(l.blockedPlayers),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => showModalBottomSheet<void>(
                        context: context,
                        builder: (_) => const _BlockedSheet(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (repo case final DemoGameRepository demo)
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
          _Group(Icons.help_outline, l.help),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: Text(l.reportProblem),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => const _SupportSheet(),
                  ),
                ),
                ListTile(
                  title: Text(l.privacyTitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(Routes.privacy),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: MkColors.red,
              side: BorderSide(color: MkColors.red.withValues(alpha: .3)),
            ),
            onPressed: () async {
              await Push.forget(ref.read(gameRepositoryProvider));
              await ref.read(authRepositoryProvider).signOut();
            },
            child: Text(l.logout),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: MkColors.faint),
            onPressed: () => _confirmDelete(context, ref),
            child: Text(l.deleteAccount),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.deleteAccountTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              l.deleteAccountSub,
              style: const TextStyle(color: MkColors.sub, height: 1.5),
            ),
            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: MkColors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.deleteAccountConfirm),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(l.cancel),
            ),
          ],
        ),
      ),
    );
    if (!(ok ?? false)) return;
    try {
      await ref.read(gameRepositoryProvider).deleteMyAccount();
      await ref.read(authRepositoryProvider).signOut();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.deleteAccountBlocked)));
    }
  }
}

class _Group extends StatelessWidget {
  const _Group(this.icon, this.label);

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 20, 4, 8),
    child: Row(
      children: [
        Icon(icon, size: 15, color: MkColors.sub),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: MkColors.sub,
            letterSpacing: .9,
          ),
        ),
      ],
    ),
  );
}

class _BlockedSheet extends ConsumerWidget {
  const _BlockedSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final list = ref.watch(_blockedProvider).value ?? const <Player>[];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.blockedPlayers,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          if (list.isEmpty)
            Text(l.noBlocked, style: const TextStyle(color: MkColors.sub)),
          for (final p in list)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: MkAvatar(p.initials, seed: p.name.length),
              title: Text(p.name),
              trailing: TextButton(
                onPressed: () =>
                    ref.read(gameRepositoryProvider).unblock(p.handle),
                child: Text(l.unblock),
              ),
            ),
        ],
      ),
    );
  }
}

class _SupportSheet extends ConsumerStatefulWidget {
  const _SupportSheet();

  @override
  ConsumerState<_SupportSheet> createState() => _SupportSheetState();
}

class _SupportSheetState extends ConsumerState<_SupportSheet> {
  final _text = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final ok = _text.text.trim().length >= 5;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.reportProblem,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            autofocus: true,
            maxLines: 5,
            maxLength: 2000,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(hintText: l.reportProblemPh),
          ),
          FilledButton(
            onPressed: !ok
                ? null
                : () async {
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    await ref
                        .read(gameRepositoryProvider)
                        .sendSupportMessage(_text.text);
                    nav.pop();
                    messenger.showSnackBar(
                      SnackBar(content: Text(l.messageSent)),
                    );
                  },
            child: Text(l.sendMessage),
          ),
        ],
      ),
    );
  }
}
