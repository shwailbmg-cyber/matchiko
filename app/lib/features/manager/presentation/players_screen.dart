import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/features/manager/presentation/providers.dart';
import 'package:matchiko/shared/providers.dart';

/// `SC.mplayers`: in-person ID verification queue.
class PlayersScreen extends ConsumerStatefulWidget {
  const PlayersScreen({super.key});

  @override
  ConsumerState<PlayersScreen> createState() => _PlayersScreenState();
}

class _PlayersScreenState extends ConsumerState<PlayersScreen> {
  /// Ticked checks per player handle: 0 name, 1 photo, 2 age.
  final _checks = <String, Set<int>>{};

  bool _checked(String handle, int i) => _checks[handle]?.contains(i) ?? false;

  void _toggle(String handle, int i) => setState(() {
    final s = _checks.putIfAbsent(handle, () => {});
    s.contains(i) ? s.remove(i) : s.add(i);
  });

  bool _ready(String handle) => (_checks[handle]?.length ?? 0) == 3;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          ref.watch(verificationQueueProvider),
          onRetry: () => ref.invalidate(verificationQueueProvider),
          data: (queue) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
            children: [
              MkTitle(l.mgPlayers),
              MkLabel('${l.verifyQ} · ${queue.length}'),
              if (queue.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      '✅ ${l.allDone}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              for (final (i, p) in queue.indexed)
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
                            value: _checked(p.handle, k),
                            onChanged: (_) => _toggle(p.handle, k),
                            title: Text(label),
                          ),
                        FilledButton(
                          onPressed: _ready(p.handle)
                              ? () => ref
                                    .read(gameRepositoryProvider)
                                    .verifyPlayer(p.handle)
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
