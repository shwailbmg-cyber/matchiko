import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/features/pitch/presentation/pitch_controller.dart';
import 'package:matchiko/shared/widgets/favorite_button.dart';
import 'package:matchiko/shared/widgets/verify_needed.dart';

/// `SC.detail` in the prototype: pitch hero, amenities, day + slot picker,
/// then the booking sheet (size, referee, cash note).
class PitchScreen extends ConsumerWidget {
  const PitchScreen(this.pitchId, {super.key});

  final String pitchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      body: AsyncView(
        ref.watch(pitchProvider(pitchId)),
        onRetry: () => ref.invalidate(pitchProvider(pitchId)),
        data: (p) {
          final vm = _PitchVm.of(ref, p);
          return Stack(
            children: [
              ListView(
                padding: const EdgeInsets.only(bottom: 120),
                children: [
                  _Hero(pitch: p),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 18),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p.name(lang),
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    '${p.district} · ${p.km} ${l.km}',
                                    style: const TextStyle(
                                      color: MkColors.sub,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '★ ${p.rating} · ${l.reviewsN(p.reviews.toString())}',
                                    style: const TextStyle(
                                      color: MkColors.sand,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  money(p.priceDa),
                                  style: const TextStyle(
                                    fontFamily: MkFonts.display,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 28,
                                  ),
                                ),
                                Text(
                                  '${l.da}${l.perHour}',
                                  style: const TextStyle(
                                    color: MkColors.sub,
                                    fontSize: 11.5,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _Features(p),
                        MkSection(l.slotsTitle),
                        _Days(vm),
                        const SizedBox(height: 14),
                        _Legend(),
                        const SizedBox(height: 10),
                        _Slots(vm),
                      ],
                    ),
                  ),
                ],
              ),
              PositionedDirectional(
                start: 0,
                end: 0,
                bottom: 0,
                child: _Footer(vm),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.pitch});

  final Pitch pitch;

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const PitchTurf(height: 230, radius: 0),
      PositionedDirectional(
        top: MediaQuery.paddingOf(context).top + 10,
        start: 16,
        end: 16,
        child: Row(
          children: [
            IconButton.filledTonal(
              style: IconButton.styleFrom(
                backgroundColor: MkColors.bg.withValues(alpha: .6),
                foregroundColor: MkColors.text,
              ),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(Routes.home),
              icon: const BackButtonIcon(),
            ),
            const Spacer(),
            DecoratedBox(
              decoration: BoxDecoration(
                color: MkColors.bg.withValues(alpha: .6),
                shape: BoxShape.circle,
              ),
              child: FavoriteButton(pitch.id),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: MkColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '≤ ${pitch.maxPerSide}v${pitch.maxPerSide}',
                style: const TextStyle(
                  color: MkColors.ink,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
      const PositionedDirectional(
        start: 0,
        end: 0,
        bottom: 0,
        height: 16,
        child: CustomPaint(painter: ZellijPainter(tile: 32, opacity: .5)),
      ),
    ],
  );
}

class _Features extends StatelessWidget {
  const _Features(this.pitch);

  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = [
      (Feature.light, Icons.lightbulb_outline, l.fLight),
      (Feature.ball, Icons.sports_soccer, l.fBall),
      (Feature.shower, Icons.shower_outlined, l.fShower),
      (Feature.roof, Icons.roofing, l.fRoof),
      (Feature.ref, Icons.sports, l.fRef),
    ];
    return Row(
      children: [
        for (final (f, icon, label) in items)
          Expanded(
            child: Opacity(
              opacity: pitch.features.contains(f) ? 1 : .35,
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 8),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: MkColors.card,
                  border: Border.all(color: MkColors.line),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: pitch.features.contains(f)
                          ? MkColors.primary
                          : MkColors.faint,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _Days extends StatelessWidget {
  const _Days(this.vm);

  final _PitchVm vm;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 64,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      itemCount: 7,
      separatorBuilder: (_, _) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final d = dayAt(i);
        final on = vm.dayIndex == i;
        return InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => vm.pickDay(i),
          child: Container(
            width: 54,
            decoration: BoxDecoration(
              color: on ? MkColors.primary : MkColors.card,
              border: Border.all(color: on ? MkColors.primary : MkColors.line),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  dayLabel(context, d).toUpperCase(),
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: on ? MkColors.ink : MkColors.sub,
                  ),
                ),
                Text(
                  '${d.day}',
                  style: TextStyle(
                    fontFamily: MkFonts.display,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: on ? MkColors.ink : MkColors.text,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

class _Legend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget item(String t, Color c) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 16),
      child: Row(
        children: [
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              color: c.withValues(alpha: .15),
              border: Border.all(color: c, width: 1.5),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(t, style: const TextStyle(fontSize: 11.5, color: MkColors.sub)),
        ],
      ),
    );
    return Row(
      children: [
        item(l.free, MkColors.primary),
        item(l.booked, MkColors.red),
        item(l.pending, MkColors.sand),
      ],
    );
  }
}

class _Slots extends StatelessWidget {
  const _Slots(this.vm);

  final _PitchVm vm;

  @override
  Widget build(BuildContext context) => GridView.count(
    crossAxisCount: 4,
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    childAspectRatio: 1.7,
    children: [
      for (final s in vm.slots)
        _SlotButton(
          slot: s,
          selected: vm.selected?.startsAt == s.startsAt,
          onTap: () => vm.pick(s),
        ),
    ],
  );
}

class _SlotButton extends StatelessWidget {
  const _SlotButton({
    required this.slot,
    required this.selected,
    required this.onTap,
  });

  final Slot slot;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = selected
        ? (MkColors.primary, MkColors.primary, MkColors.ink)
        : switch (slot.state) {
            SlotState.free => (
              MkColors.primary.withValues(alpha: .07),
              MkColors.primary.withValues(alpha: .32),
              MkColors.primary,
            ),
            SlotState.booked => (
              MkColors.red.withValues(alpha: .06),
              MkColors.red.withValues(alpha: .2),
              const Color(0x99F08C8C),
            ),
            SlotState.pending => (
              Colors.transparent,
              MkColors.sand.withValues(alpha: .5),
              MkColors.sand,
            ),
          };
    return Semantics(
      button: slot.state == SlotState.free,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: slot.state == SlotState.free ? onTap : null,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            border: Border.all(color: border),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            hhmm(slot.startsAt),
            style: TextStyle(
              fontFamily: MkFonts.display,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: fg,
            ),
          ),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer(this.vm);

  final _PitchVm vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = vm.selected;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        20 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: const [.72, 1],
          colors: [MkColors.bg, MkColors.bg.withValues(alpha: 0)],
        ),
      ),
      child: FilledButton(
        onPressed: s == null ? null : () => _openBookSheet(context, vm),
        child: Text(
          s == null
              ? l.pickSlot
              : '${l.book(hhmm(s.startsAt))} · ${money(vm.pitch.priceDa)} ${l.da}',
        ),
      ),
    );
  }
}

Future<void> _openBookSheet(BuildContext context, _PitchVm vm) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _BookSheet(vm.pitch),
    );

class _BookSheet extends ConsumerWidget {
  const _BookSheet(this.pitch);

  final Pitch pitch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = _PitchVm.of(ref, pitch);
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final p = vm.pitch;
    final s = vm.selected;
    if (s == null) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.reqTitle,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          Text(
            '${p.name(lang)} · ${dayLabel(context, s.startsAt)} · '
            '${hhmm(s.startsAt)}–${hhmm(s.startsAt.add(const Duration(hours: 1)))}',
            style: const TextStyle(color: MkColors.sub, fontSize: 13),
          ),
          MkLabel(l.gameSize),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var n = 3; n <= p.maxPerSide; n++)
                ChoiceChip(
                  label: Text('${n}v$n'),
                  selected: vm.perSide == n,
                  onSelected: (_) => vm.setSize(n),
                ),
            ],
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: vm.withReferee,
            onChanged: (_) => vm.toggleReferee(),
            title: Text(
              '🟨 ${l.addRef}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              l.addRefSub,
              style: const TextStyle(color: MkColors.sub),
            ),
          ),
          const Divider(color: MkColors.line),
          Row(
            children: [
              Text(l.total, style: const TextStyle(color: MkColors.sub)),
              const Spacer(),
              Text(
                '${money(vm.total)} ${l.da}',
                style: const TextStyle(
                  fontFamily: MkFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MkColors.sand.withValues(alpha: .08),
              border: Border.all(color: MkColors.sand.withValues(alpha: .22)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              l.cashNote,
              style: const TextStyle(
                color: Color(0xFFF1DCA4),
                fontSize: 12.5,
                height: 1.5,
              ),
            ),
          ),
          FilledButton(
            onPressed: vm.booking ? null : () => _send(context, vm),
            child: Text(l.send),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.cancel),
          ),
        ],
      ),
    );
  }

  Future<void> _send(BuildContext context, _PitchVm vm) async {
    final l = AppLocalizations.of(context);
    final nav = Navigator.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final id = await vm.book();
      nav.pop();
      messenger.showSnackBar(
        SnackBar(content: Text('${l.sent} · ${l.sentSub}')),
      );
      unawaited(router.push(Routes.game(id)));
    } on NotVerifiedException {
      nav.pop();
      if (context.mounted) await showVerifyNeeded(context);
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.genericError)));
    }
  }
}

/// The pitch page's data and actions in one place for its parts.
class _PitchVm {
  _PitchVm._(this.pitch, this.draft, this.slots, this._c);

  factory _PitchVm.of(WidgetRef ref, Pitch pitch) {
    final draft = ref.watch(pitchControllerProvider(pitch.id));
    final slots =
        ref
            .watch(slotsProvider((pitchId: pitch.id, day: draft.dayIndex)))
            .value ??
        const <Slot>[];
    return _PitchVm._(
      pitch,
      draft,
      slots,
      ref.read(pitchControllerProvider(pitch.id).notifier),
    );
  }

  final Pitch pitch;
  final BookingDraft draft;
  final List<Slot> slots;
  final PitchController _c;

  int get dayIndex => draft.dayIndex;
  int get perSide => draft.perSide == 0 ? pitch.maxPerSide : draft.perSide;
  bool get withReferee => draft.withReferee;
  bool get booking => draft.sending;
  int get total => pitch.priceDa + (withReferee ? refereeFeeDa : 0);

  /// The picked slot, if it is still free after a refresh.
  Slot? get selected {
    final s = draft.selected;
    final free = slots.any(
      (x) => x.startsAt == s?.startsAt && x.state == SlotState.free,
    );
    return free ? s : null;
  }

  void pickDay(int i) => _c.pickDay(i);
  void pick(Slot s) => _c.pick(s);
  void setSize(int n) => _c.setSize(n);
  void toggleReferee() => _c.toggleReferee();
  Future<String> book() => _c.book(perSide: perSide);
}
