import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/logo_mark.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/team.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/badges.dart';

final _teamProvider = FutureProvider.autoDispose.family<Team, String>(
  (ref, id) => watchGames(ref).team(id),
);

final _pitchesProvider = FutureProvider.autoDispose<List<Pitch>>(
  (ref) => watchGames(ref).pitches(),
);

/// Weekday name in the app language (1 = Monday).
String weekdayName(BuildContext context, int weekday) =>
    DateFormat.EEEE(Localizations.localeOf(context).languageCode)
        .format(DateTime(2024, 1, weekday)); // 1 Jan 2024 was a Monday.

/// Team page: record, usual weekly game, members, captain tools.
class TeamScreen extends ConsumerWidget {
  const TeamScreen(this.teamId, {super.key});

  final String teamId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repo = ref.read(gameRepositoryProvider);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg),
      body: AsyncView(
        ref.watch(_teamProvider(teamId)),
        onRetry: () => ref.invalidate(_teamProvider(teamId)),
        data: (t) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            Row(
              children: [
                const LogoMark(size: 56),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${t.perSide}v${t.perSide} · ${l.members('${t.members.length}')} · ${t.record}',
                        style: const TextStyle(color: MkColors.sub),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            MkLabel(l.usualGame),
            _UsualGame(t),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: () => context.go(Routes.play),
              icon: const Icon(Icons.sports_soccer),
              label: Text(l.findOpp),
            ),
            MkLabel(l.members('${t.members.length}')),
            for (final m in t.members)
              _Member(
                m,
                captain: m.handle == t.captainHandle,
                onRemove: t.iAmCaptain && m.handle != t.captainHandle
                    ? () => repo.removeTeamMember(t.id, m.handle)
                    : null,
              ),
            if (t.iAmCaptain)
              TextButton.icon(
                onPressed: () => _addMember(context, ref, t),
                icon: const Icon(Icons.person_add_alt_1),
                label: Text(l.addMember),
              )
            else
              TextButton(
                style: TextButton.styleFrom(foregroundColor: MkColors.red),
                onPressed: () async {
                  final router = GoRouter.of(context);
                  final me = await ref.read(meProvider.future);
                  await repo.removeTeamMember(t.id, me.handle);
                  router.pop();
                },
                child: Text(l.leaveTeam),
              ),
          ],
        ),
      ),
    );
  }

  /// Pick one of my friends who is not in the team yet.
  Future<void> _addMember(BuildContext context, WidgetRef ref, Team t) async {
    final repo = ref.read(gameRepositoryProvider);
    final friends = (await repo.friends())
        .where((p) => p.friend == FriendStatus.friends)
        .where((p) => !t.members.any((m) => m.handle == p.handle))
        .toList();
    if (!context.mounted) return;
    final l = AppLocalizations.of(context);
    final handle = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => friends.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(24),
              child: Text(l.noFriends, textAlign: TextAlign.center),
            )
          : ListView(
              shrinkWrap: true,
              children: [
                for (final f in friends)
                  ListTile(
                    leading: MkAvatar(f.initials, seed: f.name.length),
                    title: Text(f.name),
                    subtitle: Text('@${f.handle}'),
                    onTap: () => Navigator.of(ctx).pop(f.handle),
                  ),
              ],
            ),
    );
    if (handle != null) await repo.addTeamMember(t.id, handle);
  }
}

class _UsualGame extends ConsumerWidget {
  const _UsualGame(this.t);

  final Team t;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final pitches = ref.watch(_pitchesProvider).value ?? const <Pitch>[];
    final pitch = pitches.where((p) => p.id == t.usualPitchId).firstOrNull;
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t.hasUsualGame
                ? l.usualGameAt(
                    weekdayName(context, t.usualWeekday!),
                    '${t.usualHour}:00',
                  )
                : l.noUsualGame,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          if (pitch != null)
            Text(pitch.name(lang), style: const TextStyle(color: MkColors.sub)),
          const SizedBox(height: 10),
          if (pitch != null)
            FilledButton(
              onPressed: () => context.push(Routes.pitch(pitch.id)),
              child: Text(l.bookUsual),
            ),
          if (t.iAmCaptain)
            TextButton(
              onPressed: () => _edit(context, ref, pitches),
              child: Text(l.setUsualGame),
            ),
        ],
      ),
    );
  }

  Future<void> _edit(
    BuildContext context,
    WidgetRef ref,
    List<Pitch> pitches,
  ) async {
    final r = await showModalBottomSheet<(int, int, String)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _UsualSheet(team: t, pitches: pitches),
    );
    if (r == null) return;
    await ref
        .read(gameRepositoryProvider)
        .setUsualGame(t.id, weekday: r.$1, hour: r.$2, pitchId: r.$3);
  }
}

class _UsualSheet extends StatefulWidget {
  const _UsualSheet({required this.team, required this.pitches});

  final Team team;
  final List<Pitch> pitches;

  @override
  State<_UsualSheet> createState() => _UsualSheetState();
}

class _UsualSheetState extends State<_UsualSheet> {
  late int _day = widget.team.usualWeekday ?? DateTime.friday;
  late int _hour = widget.team.usualHour ?? 21;
  late String? _pitch =
      widget.team.usualPitchId ?? widget.pitches.firstOrNull?.id;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l.setUsualGame,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          MkLabel(l.day),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var d = 1; d <= 7; d++)
                ChoiceChip(
                  label: Text(weekdayName(context, d)),
                  selected: _day == d,
                  onSelected: (_) => setState(() => _day = d),
                ),
            ],
          ),
          MkLabel(l.hour),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (var h = 16; h <= 23; h++)
                ChoiceChip(
                  label: Text('$h:00'),
                  selected: _hour == h,
                  onSelected: (_) => setState(() => _hour = h),
                ),
            ],
          ),
          MkLabel(l.pitch),
          DropdownButton<String>(
            value: _pitch,
            isExpanded: true,
            items: [
              for (final p in widget.pitches)
                DropdownMenuItem(value: p.id, child: Text(p.name(lang))),
            ],
            onChanged: (v) => setState(() => _pitch = v),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _pitch == null
                ? null
                : () => Navigator.of(context).pop((_day, _hour, _pitch!)),
            child: Text(l.save),
          ),
        ],
      ),
    );
  }
}

class _Member extends StatelessWidget {
  const _Member(this.p, {required this.captain, this.onRemove});

  final Player p;
  final bool captain;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MkCard(
        padding: const EdgeInsets.all(12),
        onTap: () => context.push(Routes.player(p.handle)),
        child: Row(
          children: [
            MkAvatar(p.initials, size: 40, seed: p.name.length),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Wrap(
                    spacing: 6,
                    children: [
                      for (final pos in p.positions) PositionBadge(pos),
                      if (captain)
                        MkTag('© ${l.captain}', color: MkColors.sand),
                    ],
                  ),
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                tooltip: l.removeMember,
                onPressed: onRemove,
                icon: const Icon(Icons.close, color: MkColors.sub),
              ),
          ],
        ),
      ),
    );
  }
}
