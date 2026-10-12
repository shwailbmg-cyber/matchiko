import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/venue_stats.dart';
import 'package:matchiko/shared/providers.dart';

enum _Period { week, month, last30 }

({DateTime from, DateTime to}) _range(_Period p) {
  final n = DateTime.now();
  final today = DateTime(n.year, n.month, n.day);
  return switch (p) {
    _Period.week => (
      from: today.subtract(Duration(days: today.weekday - 1)),
      to: today.add(Duration(days: 8 - today.weekday)),
    ),
    _Period.month => (
      from: DateTime(n.year, n.month),
      to: DateTime(n.year, n.month + 1),
    ),
    _Period.last30 => (
      from: today.subtract(const Duration(days: 29)),
      to: today.add(const Duration(days: 1)),
    ),
  };
}

final _statsProvider = FutureProvider.autoDispose.family<VenueStats, _Period>((
  ref,
  p,
) {
  final r = _range(p);
  return watchGames(ref).venueStats(r.from, r.to);
});

final _staffProvider = FutureProvider.autoDispose<List<StaffMember>>(
  (ref) => watchGames(ref).venueStaff(),
);

/// Manager reports: bookings, cash expected vs received, occupancy; staff.
class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  _Period _period = _Period.week;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.reports)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          SegmentedButton<_Period>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: _Period.week, label: Text(l.thisWeek)),
              ButtonSegment(value: _Period.month, label: Text(l.thisMonth)),
              ButtonSegment(value: _Period.last30, label: Text(l.last30)),
            ],
            selected: {_period},
            onSelectionChanged: (s) => setState(() => _period = s.first),
          ),
          const SizedBox(height: 12),
          AsyncView(
            ref.watch(_statsProvider(_period)),
            onRetry: () => ref.invalidate(_statsProvider(_period)),
            data: (s) => _Stats(s),
          ),
          MkLabel(l.staff),
          const _Staff(),
        ],
      ),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats(this.s);

  final VenueStats s;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Tile(
                '${money(s.cashReceivedDa)} ${l.da}',
                l.cashReceived,
                MkColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _Tile(
                '${money(s.cashExpectedDa)} ${l.da}',
                l.cashExpected,
                MkColors.text,
              ),
            ),
          ],
        ),
        if (s.cashMissingDa > 0)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              l.cashToCollect('${money(s.cashMissingDa)} ${l.da}'),
              style: const TextStyle(color: MkColors.sand),
            ),
          ),
        const SizedBox(height: 8),
        MkCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.occupancy,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                  Text(
                    '${(s.occupancy * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: MkFonts.display,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: s.occupancy,
                  minHeight: 8,
                  backgroundColor: MkColors.card2,
                  color: MkColors.primary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l.hoursBooked('${s.bookedHours}', '${s.openHours}'),
                style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: .95,
          children: [
            _Tile('${s.bookings}', l.bookings, MkColors.text),
            _Tile('${s.walkIns}', l.walkIn, MkColors.blue),
            _Tile('${s.requested}', l.toConfirm, MkColors.sand),
            _Tile('${s.guaranteed + s.completed}', l.paid, MkColors.primary),
            _Tile('${s.cancelled}', l.cancelled, MkColors.sub),
            _Tile('${s.noShows}', l.noshow, MkColors.red),
          ],
        ),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => MkCard(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: MkFonts.display,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
        Text(
          label,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: MkColors.sub, fontSize: 11.5),
        ),
      ],
    ),
  );
}

class _Staff extends ConsumerStatefulWidget {
  const _Staff();

  @override
  ConsumerState<_Staff> createState() => _StaffState();
}

class _StaffState extends ConsumerState<_Staff> {
  final _handle = TextEditingController();

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  Future<void> _add() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(gameRepositoryProvider).addStaff(_handle.text);
      _handle.clear();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.staffNotFound)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final staff = ref.watch(_staffProvider).value ?? const <StaffMember>[];
    final repo = ref.read(gameRepositoryProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final m in staff)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: MkCard(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  MkAvatar(
                    m.name.split(' ').map((w) => w[0]).take(2).join(),
                    seed: m.name.length,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      m.isMe ? '${m.name} (${l.you})' : m.name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (!m.isMe && staff.length > 1)
                    IconButton(
                      tooltip: l.removeStaff,
                      onPressed: () => repo.removeStaff(m.handle),
                      icon: const Icon(Icons.close, color: MkColors.sub),
                    ),
                ],
              ),
            ),
          ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _handle,
                decoration: InputDecoration(hintText: l.staffHandle),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: _add,
              child: Text(l.addStaff),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          l.staffSub,
          style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
        ),
      ],
    );
  }
}
