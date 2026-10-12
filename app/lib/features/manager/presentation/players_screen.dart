import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/features/manager/presentation/providers.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/venue_review.dart';
import 'package:matchiko/shared/providers.dart';

/// `SC.mplayers`: ID verification queue, referee requests, reports.
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
                Text(
                  '✅ ${l.allDone}',
                  style: const TextStyle(color: MkColors.sub),
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
              const _RefRequests(),
              const _Reports(),
            ],
          ),
        ),
      ),
    );
  }
}

final _refAppsProvider = FutureProvider.autoDispose<List<RefApplication>>(
  (ref) => watchGames(ref).refereeApplications(),
);

final _reportsProvider = FutureProvider.autoDispose<List<VenueReport>>(
  (ref) => watchGames(ref).venueReports(),
);

/// Referee requests: approve after checking the ID (verified players only).
class _RefRequests extends ConsumerWidget {
  const _RefRequests();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final apps = ref.watch(_refAppsProvider).value ?? const [];
    if (apps.isEmpty) return const SizedBox.shrink();
    final repo = ref.read(gameRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MkLabel('${l.refRequests} · ${apps.length}'),
        for (final a in apps)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MkCard(
              child: Row(
                children: [
                  MkAvatar(a.player.initials, seed: a.player.name.length),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${a.player.name}\n@${a.player.handle}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton.filled(
                    tooltip: l.approve,
                    onPressed: () =>
                        repo.decideRefereeApplication(a.id, approve: true),
                    icon: const Icon(Icons.check),
                  ),
                  IconButton.outlined(
                    tooltip: l.reject,
                    onPressed: () =>
                        repo.decideRefereeApplication(a.id, approve: false),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// Reports about games here; confirming a no-show applies the penalty.
class _Reports extends ConsumerWidget {
  const _Reports();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final reports = ref.watch(_reportsProvider).value ?? const [];
    if (reports.isEmpty) return const SizedBox.shrink();
    final repo = ref.read(gameRepositoryProvider);
    final reasons = {
      ReportReason.noShow: l.rsNoShow,
      ReportReason.late: l.rsLate,
      ReportReason.rude: l.rsRude,
      ReportReason.unsafe: l.rsUnsafe,
      ReportReason.other: l.rsOther,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        MkLabel('${l.reportsToReview} · ${reports.length}'),
        for (final r in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MkCard(
              borderColor: MkColors.red.withValues(alpha: .4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${r.reported.name} · ${reasons[r.reason]}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    '${l.reportedBy(r.reporterName)} · '
                    '${dayLabel(context, r.gameStartsAt)} ${hhmm(r.gameStartsAt)}',
                    style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                  ),
                  if (r.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text('“${r.note}”'),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 40),
                            backgroundColor: MkColors.red,
                          ),
                          onPressed: () =>
                              repo.reviewReport(r.id, accept: true),
                          child: Text(l.acceptReport),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(0, 40),
                          ),
                          onPressed: () =>
                              repo.reviewReport(r.id, accept: false),
                          child: Text(l.rejectReport),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
