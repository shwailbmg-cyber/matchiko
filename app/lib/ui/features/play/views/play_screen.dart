import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/position.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../../routing/routes.dart';
import '../../../core/format.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/theme/mk_theme.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/mk_widgets.dart';
import '../view_models/play_view_model.dart';

/// `SC.play` → `SC.searching` → `SC.found` in the prototype.
class PlayScreen extends StatelessWidget {
  const PlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PlayViewModel>();
    return Scaffold(
      body: SafeArea(
        child: switch (vm.stage) {
          PlayStage.form => _Form(vm),
          PlayStage.searching => _Searching(vm),
          PlayStage.found => _Found(vm),
          PlayStage.none => _NoneFound(vm),
        },
      ),
    );
  }
}

class _Form extends StatelessWidget {
  const _Form(this.vm);

  final PlayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final windows = {
      TimeWindow.morning: (l.morning, '08–12'),
      TimeWindow.afternoon: (l.afternoon, '12–17'),
      TimeWindow.evening: (l.evening, '17–21'),
      TimeWindow.night: (l.night, '21–00'),
    };
    final modes = {
      PlayMode.solo: (Icons.person_outline, l.mSolo, l.mSoloSub),
      PlayMode.friends: (Icons.group_outlined, l.mFriends, l.mFriendsSub),
      PlayMode.team: (Icons.shield_outlined, l.mTeam, l.mTeamSub),
    };
    final now = DateTime.now();
    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(20, 6, 20, 120),
          children: [
            MkTitle(l.playTitle, size: 42),
            const SizedBox(height: 6),
            Text(l.playHint, style: const TextStyle(color: MkColors.sub)),
            MkLabel(l.mode),
            Row(
              children: [
                for (final e in modes.entries)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: _Choice(
                        on: vm.mode == e.key,
                        onTap: () => vm.setMode(e.key),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              e.value.$1,
                              color: vm.mode == e.key
                                  ? MkColors.lime
                                  : MkColors.sub,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              e.value.$2,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              e.value.$3,
                              style: const TextStyle(
                                fontSize: 11,
                                color: MkColors.sub,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            MkLabel('${l.positions} · ${l.posHint}'),
            Row(
              children: [
                for (final p in Position.playable)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: _Choice(
                        on: vm.positions.contains(p),
                        onTap: () => vm.togglePosition(p),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: Column(
                                children: [
                                  Text(
                                    p.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    positionName(l, p),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (vm.positions.contains(p))
                              PositionedDirectional(
                                top: -4,
                                end: -4,
                                child: CircleAvatar(
                                  radius: 9,
                                  backgroundColor: MkColors.lime,
                                  child: Text(
                                    '${vm.positions.indexOf(p) + 1}',
                                    style: const TextStyle(
                                      color: MkColors.ink,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            MkLabel(l.day),
            SizedBox(
              height: 40,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 5,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text(dayLabel(context, now.add(Duration(days: i)))),
                  selected: vm.day == i,
                  onSelected: (_) => vm.setDay(i),
                ),
              ),
            ),
            MkLabel(l.window),
            GridView(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                mainAxisExtent: 74,
              ),
              children: [
                for (final e in windows.entries)
                  _Choice(
                    on: vm.windows.contains(e.key),
                    onTap: () => vm.toggleWindow(e.key),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          e.value.$1,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          e.value.$2,
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(
                            fontFamily: MkFonts.display,
                            fontSize: 16,
                            color: MkColors.sub,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            MkLabel('${l.distance} · ${vm.radiusKm.round()} ${l.km}'),
            Slider(
              value: vm.radiusKm,
              min: 1,
              max: 20,
              divisions: 19,
              label: '${vm.radiusKm.round()} ${l.km}',
              onChanged: vm.setRadius,
            ),
            MkCard(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: SwitchListTile(
                value: vm.referee,
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
            ),
          ],
        ),
        PositionedDirectional(
          start: 0,
          end: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                stops: const [.72, 1],
                colors: [MkColors.bg, MkColors.bg.withValues(alpha: 0)],
              ),
            ),
            child: FilledButton.icon(
              onPressed: vm.search,
              icon: const Icon(Icons.bolt),
              label: Text(vm.mode == PlayMode.team ? l.findOpp : l.find),
            ),
          ),
        ),
      ],
    );
  }
}

class _Choice extends StatelessWidget {
  const _Choice({required this.on, required this.onTap, required this.child});

  final bool on;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) => Semantics(
    selected: on,
    button: true,
    child: InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: on ? MkColors.lime.withValues(alpha: .1) : MkColors.card,
          border: Border.all(color: on ? MkColors.lime : MkColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        child: child,
      ),
    ),
  );
}

class _Searching extends StatelessWidget {
  const _Searching(this.vm);

  final PlayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final steps = [l.s1, l.s2, l.s3, l.s4];
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [_Pulse(), LogoMark(size: 64)],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l.searching,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 20),
            for (var i = 0; i < 4; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      i < vm.step
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      size: 22,
                      color: i < vm.step ? MkColors.lime : MkColors.line2,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 220,
                      child: Text(
                        steps[i],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: i <= vm.step ? MkColors.text : MkColors.faint,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            OutlinedButton(onPressed: vm.reset, child: Text(l.cancelSearch)),
          ],
        ),
      ),
    );
  }
}

class _Pulse extends StatefulWidget {
  const _Pulse();

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) => Stack(
      alignment: Alignment.center,
      children: [
        for (var k = 0; k < 3; k++)
          Builder(
            builder: (_) {
              final t = (_c.value + k / 3) % 1;
              return Container(
                width: 60 + 160 * t,
                height: 60 + 160 * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: MkColors.lime.withValues(alpha: .5 * (1 - t)),
                    width: 1.5,
                  ),
                ),
              );
            },
          ),
      ],
    ),
  );
}

class _Found extends StatelessWidget {
  const _Found(this.vm);

  final PlayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final g = vm.offer!;
    final color = vm.secondsLeft > 15
        ? MkColors.lime
        : vm.secondsLeft > 7
        ? MkColors.sand
        : MkColors.red;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Center(child: MkTag('⚡ ${l.found.toUpperCase()}')),
        const SizedBox(height: 10),
        Text(
          g.pitch.name(lang),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
        ),
        Text(
          '${dayLabel(context, g.startsAt)} · ${hhmm(g.startsAt)} · ${g.perSide}v${g.perSide} · '
          '${l.each(money(g.share.perPlayer))}',
          textAlign: TextAlign.center,
          style: const TextStyle(color: MkColors.sub),
        ),
        const SizedBox(height: 20),
        MkCard(
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 96,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox.expand(
                      child: CircularProgressIndicator(
                        value: vm.secondsLeft / vm.offerTime,
                        strokeWidth: 7,
                        color: color,
                        backgroundColor: MkColors.card2,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${vm.secondsLeft}',
                          style: TextStyle(
                            fontFamily: MkFonts.display,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                        Text(
                          l.sec,
                          style: const TextStyle(
                            fontSize: 11,
                            color: MkColors.sub,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.acceptWithin,
                      style: const TextStyle(color: MkColors.sub),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⚖️ ${l.balanced}',
                      style: const TextStyle(
                        color: MkColors.sub,
                        fontSize: 12.5,
                      ),
                    ),
                    Text(
                      l.spots(g.spotsLeft.toString()),
                      style: const TextStyle(
                        color: MkColors.sand,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        PitchTurf(height: 176, radius: 18),
        const SizedBox(height: 20),
        Row(
          children: [
            OutlinedButton(onPressed: vm.reset, child: Text(l.pass)),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final id = await vm.accept();
                  if (id != null) unawaited(router.push(Routes.game(id)));
                },
                icon: const Icon(Icons.bolt),
                label: Text(l.accept),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NoneFound extends StatelessWidget {
  const _NoneFound(this.vm);

  final PlayViewModel vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(size: 64),
            const SizedBox(height: 16),
            Text(
              l.noGameYet,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              l.noGameYetSub,
              textAlign: TextAlign.center,
              style: const TextStyle(color: MkColors.sub),
            ),
            const SizedBox(height: 20),
            FilledButton(onPressed: vm.reset, child: Text(l.done)),
          ],
        ),
      ),
    );
  }
}
