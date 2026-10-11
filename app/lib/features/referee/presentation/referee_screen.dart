import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/referee.dart';
import 'package:matchiko/shared/providers.dart';

final _statusProvider = FutureProvider.autoDispose<RefereeStatus>(
  (ref) => watchGames(ref).refereeStatus(),
);

typedef _BoardData = ({List<RefJob> jobs, List<RefAvailability> availability});

final _boardProvider = FutureProvider.autoDispose<_BoardData>((ref) async {
  final repo = watchGames(ref);
  final r = await Future.wait([repo.refereeJobs(), repo.refereeAvailability()]);
  return (
    jobs: r[0] as List<RefJob>,
    availability: r[1] as List<RefAvailability>,
  );
});

/// Referee hub: apply, then availability, job board, my games, earnings.
class RefereeScreen extends ConsumerWidget {
  const RefereeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.referee)),
      body: AsyncView(
        ref.watch(_statusProvider),
        onRetry: () => ref.invalidate(_statusProvider),
        data: (status) => switch (status) {
          RefereeStatus.none => const _Apply(),
          RefereeStatus.pending => _Message('⏳', l.refPending),
          RefereeStatus.approved => const _Board(),
        },
      ),
    );
  }
}

class _Message extends StatelessWidget {
  const _Message(this.emoji, this.text);

  final String emoji;
  final String text;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MkColors.sub, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

class _Apply extends ConsumerStatefulWidget {
  const _Apply();

  @override
  ConsumerState<_Apply> createState() => _ApplyState();
}

class _ApplyState extends ConsumerState<_Apply> {
  String? _pitch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final me = ref.watch(meProvider).value;
    final pitches = ref.watch(_pitchesProvider).value ?? const <Pitch>[];
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text('🟨', style: TextStyle(fontSize: 48)),
        MkTitle(l.becomeReferee, size: 32),
        const SizedBox(height: 8),
        Text(
          l.becomeRefereeSub(money(refereeFeeDa)),
          style: const TextStyle(color: MkColors.sub, height: 1.5),
        ),
        MkLabel(l.refVenue),
        DropdownButton<String>(
          value: _pitch,
          isExpanded: true,
          hint: Text(l.refVenue),
          items: [
            for (final p in pitches)
              DropdownMenuItem(value: p.id, child: Text(p.name(lang))),
          ],
          onChanged: (v) => setState(() => _pitch = v),
        ),
        if (me != null && !me.verified)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '🪪 ${l.refVerifyFirst}',
              style: const TextStyle(color: MkColors.sand),
            ),
          ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _pitch == null
              ? null
              : () => ref
                    .read(gameRepositoryProvider)
                    .applyReferee(pitchId: _pitch!),
          child: Text(l.applyReferee),
        ),
      ],
    );
  }
}

final _pitchesProvider = FutureProvider.autoDispose<List<Pitch>>(
  (ref) => watchGames(ref).pitches(),
);

class _Board extends ConsumerWidget {
  const _Board();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repo = ref.read(gameRepositoryProvider);
    return AsyncView(
      ref.watch(_boardProvider),
      onRetry: () => ref.invalidate(_boardProvider),
      data: (b) {
        final now = DateTime.now();
        final open = b.jobs.where((j) => !j.mine).toList();
        final mine = b.jobs.where((j) => j.mine).toList();
        final toReport = mine.where((j) => j.needsReport(now)).toList();
        final upcoming = mine.where((j) => j.startsAt.isAfter(now)).toList();
        final done = mine.where((j) => j.reported).length;
        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Row(
              children: [
                Expanded(child: _Num('$done', l.refGamesDone)),
                const SizedBox(width: 8),
                Expanded(
                  child: _Num(
                    '${money(done * refereeFeeDa)} ${l.da}',
                    l.refEarned,
                  ),
                ),
              ],
            ),
            if (toReport.isNotEmpty) ...[
              MkLabel(l.refToReport),
              for (final j in toReport)
                _JobTile(
                  j,
                  action: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 40),
                    ),
                    onPressed: () =>
                        context.push(Routes.matchReport(j.gameId!)),
                    child: Text(l.refOpen),
                  ),
                ),
            ],
            MkLabel(l.refJobs),
            if (open.isEmpty)
              Text(l.refNoJobs, style: const TextStyle(color: MkColors.sub)),
            for (final j in open)
              _JobTile(
                j,
                action: FilledButton(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      await repo.takeRefereeJob(j.bookingId);
                    } catch (_) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l.refClash)),
                      );
                    }
                  },
                  child: Text(l.refTake),
                ),
              ),
            if (upcoming.isNotEmpty) ...[
              MkLabel(l.refMine),
              for (final j in upcoming) _JobTile(j),
            ],
            MkLabel(l.refAvailability),
            _Availability(b.availability),
          ],
        );
      },
    );
  }
}

class _JobTile extends StatelessWidget {
  const _JobTile(this.j, {this.action});

  final RefJob j;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: MkCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${dayLabel(context, j.startsAt)} · ${hhmm(j.startsAt)}',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  '${j.venue} · ${j.perSide}v${j.perSide}',
                  style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                ),
              ],
            ),
          ),
          ?action,
        ],
      ),
    ),
  );
}

class _Num extends StatelessWidget {
  const _Num(this.value, this.label);

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => MkCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: MkFonts.display,
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: MkColors.sand,
            ),
          ),
        ),
        Text(label, style: const TextStyle(color: MkColors.sub, fontSize: 12)),
      ],
    ),
  );
}

/// One row per weekday: off, or a start–end range.
class _Availability extends ConsumerWidget {
  const _Availability(this.list);

  final List<RefAvailability> list;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final repo = ref.read(gameRepositoryProvider);
    final byDay = {for (final a in list) a.weekday: a};
    return MkCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var d = 1; d <= 7; d++)
            SwitchListTile(
              dense: true,
              title: Text(
                DateFormat.EEEE(lang).format(DateTime(2024, 1, d)),
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text(
                byDay[d] == null
                    ? l.refOff
                    : '${byDay[d]!.startHour}:00 – ${byDay[d]!.endHour}:00',
                style: const TextStyle(color: MkColors.sub),
              ),
              value: byDay[d] != null,
              onChanged: (on) => on
                  ? repo.setRefereeAvailability(
                      RefAvailability(weekday: d, startHour: 18, endHour: 23),
                    )
                  : repo.clearRefereeAvailability(d),
            ),
        ],
      ),
    );
  }
}
