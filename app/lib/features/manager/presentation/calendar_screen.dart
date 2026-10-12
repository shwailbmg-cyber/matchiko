import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/calendar_entry.dart';
import 'package:matchiko/shared/domain/phone_number.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/badges.dart';

final _pitchesProvider = FutureProvider.autoDispose<List<Pitch>>(
  (ref) => watchGames(ref).venuePitches(),
);

final _weekProvider = FutureProvider.autoDispose
    .family<List<CalendarEntry>, ({String pitchId, DateTime from})>(
      (ref, k) => watchGames(ref).venueWeek(k.pitchId, k.from),
    );

/// Opening hours shown in the calendar.
const _firstHour = 8, _lastHour = 23;

DateTime _midnight(DateTime t) => DateTime(t.year, t.month, t.day);

/// Manager calendar: a week per pitch, block an hour or add a walk-in.
class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _from = _midnight(DateTime.now());
  int _day = 0;
  String? _pitchId;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: SafeArea(
        child: AsyncView(
          ref.watch(_pitchesProvider),
          onRetry: () => ref.invalidate(_pitchesProvider),
          data: (pitches) {
            if (pitches.isEmpty) return const SizedBox.shrink();
            final pitch = pitches.firstWhere(
              (p) => p.id == _pitchId,
              orElse: () => pitches.first,
            );
            final week =
                ref
                    .watch(_weekProvider((pitchId: pitch.id, from: _from)))
                    .value ??
                const <CalendarEntry>[];
            final day = _from.add(Duration(days: _day));
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
              children: [
                Row(
                  children: [
                    Expanded(child: MkTitle(l.calendar, size: 32)),
                    IconButton(
                      tooltip: l.prevWeek,
                      onPressed: () => setState(
                        () => _from = _from.subtract(const Duration(days: 7)),
                      ),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    IconButton(
                      tooltip: l.nextWeek,
                      onPressed: () => setState(
                        () => _from = _from.add(const Duration(days: 7)),
                      ),
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                if (pitches.length > 1)
                  DropdownButton<String>(
                    value: pitch.id,
                    isExpanded: true,
                    items: [
                      for (final p in pitches)
                        DropdownMenuItem(
                          value: p.id,
                          child: Text(p.name(lang)),
                        ),
                    ],
                    onChanged: (v) => setState(() => _pitchId = v),
                  )
                else
                  Text(
                    pitch.name(lang),
                    style: const TextStyle(color: MkColors.sub),
                  ),
                const SizedBox(height: 12),
                _Days(
                  from: _from,
                  selected: _day,
                  busy: [
                    for (var i = 0; i < 7; i++)
                      week
                          .where(
                            (e) =>
                                _midnight(e.startsAt) ==
                                _from.add(Duration(days: i)),
                          )
                          .length,
                  ],
                  onPick: (i) => setState(() => _day = i),
                ),
                const SizedBox(height: 12),
                for (var h = _firstHour; h <= _lastHour; h++)
                  _HourRow(
                    time: DateTime(day.year, day.month, day.day, h),
                    entry: week
                        .where(
                          (e) =>
                              e.startsAt ==
                              DateTime(day.year, day.month, day.day, h),
                        )
                        .firstOrNull,
                    pitchId: pitch.id,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _Days extends StatelessWidget {
  const _Days({
    required this.from,
    required this.selected,
    required this.busy,
    required this.onPick,
  });

  final DateTime from;
  final int selected;
  final List<int> busy;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: Row(
      children: [
        for (var i = 0; i < 7; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.only(end: 4),
              child: Material(
                color: i == selected ? MkColors.primary : MkColors.card,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => onPick(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        weekdayShort(context, from.add(Duration(days: i))),
                        style: TextStyle(
                          fontSize: 11,
                          color: i == selected ? MkColors.ink : MkColors.sub,
                        ),
                      ),
                      Text(
                        '${from.add(Duration(days: i)).day}',
                        style: TextStyle(
                          fontFamily: MkFonts.display,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: i == selected ? MkColors.ink : MkColors.text,
                        ),
                      ),
                      Text(
                        busy[i] == 0 ? '' : '${busy[i]}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: i == selected ? MkColors.ink : MkColors.sand,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class _HourRow extends ConsumerWidget {
  const _HourRow({
    required this.time,
    required this.entry,
    required this.pitchId,
  });

  final DateTime time;
  final CalendarEntry? entry;
  final String pitchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final e = entry;
    final past = time.isBefore(DateTime.now());
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              hhmm(time),
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: MkFonts.display,
                fontSize: 16,
                color: MkColors.sub,
              ),
            ),
          ),
          Expanded(
            child: MkCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderColor: switch (e?.kind) {
                CalendarKind.blocked => MkColors.red.withValues(alpha: .5),
                CalendarKind.walkIn => MkColors.blue.withValues(alpha: .5),
                CalendarKind.booking => MkColors.primary.withValues(alpha: .5),
                null => null,
              },
              onTap: switch (e?.kind) {
                null => past ? null : () => _openFree(context, ref),
                CalendarKind.booking => null,
                _ => () => _openBlock(context, ref, e!),
              },
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      switch (e?.kind) {
                        null => l.freeSlot,
                        CalendarKind.blocked =>
                          '🔒 ${e!.label.isEmpty ? l.blocked : e.label}',
                        CalendarKind.walkIn => '🚶 ${e!.label}',
                        CalendarKind.booking => e!.label,
                      },
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: e == null ? MkColors.faint : MkColors.text,
                      ),
                    ),
                  ),
                  if (e?.status case final s?) StatusTag(s),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openFree(BuildContext context, WidgetRef ref) async {
    final repo = ref.read(gameRepositoryProvider);
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final r = await showModalBottomSheet<_SlotAction>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _FreeSheet(time: time),
    );
    if (r == null) return;
    try {
      if (r.walkIn) {
        await repo.addWalkIn(pitchId, time, name: r.text, phone: r.phone);
      } else {
        await repo.blockSlot(pitchId, time, reason: r.text);
      }
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.slotTaken)));
    }
  }

  Future<void> _openBlock(
    BuildContext context,
    WidgetRef ref,
    CalendarEntry e,
  ) async {
    final l = AppLocalizations.of(context);
    final ok = await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              e.kind == CalendarKind.walkIn ? l.walkIn : l.blocked,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            Text(
              '${dayLabel(context, e.startsAt)} · ${hhmm(e.startsAt)}',
              style: const TextStyle(color: MkColors.sub),
            ),
            if (e.label.isNotEmpty) Text(e.label),
            if (e.phone != null)
              SelectableText(
                e.phone!,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            const SizedBox(height: 16),
            OutlinedButton(
              style: OutlinedButton.styleFrom(foregroundColor: MkColors.red),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l.freeThisHour),
            ),
          ],
        ),
      ),
    );
    if (ok ?? false) await ref.read(gameRepositoryProvider).removeBlock(e.id);
  }
}

typedef _SlotAction = ({bool walkIn, String text, String? phone});

class _FreeSheet extends StatefulWidget {
  const _FreeSheet({required this.time});

  final DateTime time;

  @override
  State<_FreeSheet> createState() => _FreeSheetState();
}

class _FreeSheetState extends State<_FreeSheet> {
  bool _walkIn = true;
  final _text = TextEditingController();
  final _phone = TextEditingController();

  @override
  void dispose() {
    _text.dispose();
    _phone.dispose();
    super.dispose();
  }

  bool get _phoneOk =>
      _phone.text.trim().isEmpty || algerianMobileE164(_phone.text) != null;

  bool get _ok => _phoneOk && (!_walkIn || _text.text.trim().length >= 2);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
            '${dayLabel(context, widget.time)} · ${hhmm(widget.time)}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          SegmentedButton<bool>(
            showSelectedIcon: false,
            segments: [
              ButtonSegment(value: true, label: Text(l.walkIn)),
              ButtonSegment(value: false, label: Text(l.blockSlot)),
            ],
            selected: {_walkIn},
            onSelectionChanged: (s) => setState(() => _walkIn = s.first),
          ),
          const SizedBox(height: 8),
          if (_walkIn)
            Text(l.walkInSub, style: const TextStyle(color: MkColors.sub)),
          const SizedBox(height: 8),
          TextField(
            controller: _text,
            maxLength: 60,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: _walkIn ? l.customerName : l.blockReason,
            ),
          ),
          if (_walkIn)
            TextField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: l.customerPhone,
                errorText: _phoneOk ? null : l.phoneInvalid,
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _ok
                ? () => Navigator.of(context).pop((
                    walkIn: _walkIn,
                    text: _text.text.trim(),
                    phone: _phone.text.trim().isEmpty
                        ? null
                        : algerianMobileE164(_phone.text),
                  ))
                : null,
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}
