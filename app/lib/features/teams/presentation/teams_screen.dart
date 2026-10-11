import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/logo_mark.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/team.dart';
import 'package:matchiko/shared/providers.dart';

final myTeamsProvider = FutureProvider.autoDispose<List<Team>>(
  (ref) => watchGames(ref).myTeams(),
);

/// My teams and "Create a team".
class TeamsScreen extends ConsumerWidget {
  const TeamsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.teams)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _create(context, ref),
        icon: const Icon(Icons.add),
        label: Text(l.createTeam),
      ),
      body: AsyncView(
        ref.watch(myTeamsProvider),
        onRetry: () => ref.invalidate(myTeamsProvider),
        data: (teams) => teams.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text(
                    l.noTeams,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: MkColors.sub),
                  ),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
                children: [for (final t in teams) TeamCard(t)],
              ),
      ),
    );
  }

  Future<void> _create(BuildContext context, WidgetRef ref) async {
    final router = GoRouter.of(context);
    final result = await showModalBottomSheet<(String, int)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _CreateSheet(),
    );
    if (result == null) return;
    final id = await ref
        .read(gameRepositoryProvider)
        .createTeam(name: result.$1, perSide: result.$2);
    await router.push(Routes.team(id));
  }
}

/// Team row: crest, name, members and size, record.
class TeamCard extends StatelessWidget {
  const TeamCard(this.team, {super.key});

  final Team team;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MkCard(
        onTap: () => context.push(Routes.team(team.id)),
        child: Row(
          children: [
            const LogoMark(size: 34),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    team.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    [
                      l.members('${team.members.length}'),
                      '${team.perSide}v${team.perSide}',
                      if (team.iAmCaptain) l.captain,
                    ].join(' · '),
                    style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                  ),
                ],
              ),
            ),
            Text(
              team.record,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: MkFonts.display,
                fontWeight: FontWeight.w700,
                fontSize: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateSheet extends StatefulWidget {
  const _CreateSheet();

  @override
  State<_CreateSheet> createState() => _CreateSheetState();
}

class _CreateSheetState extends State<_CreateSheet> {
  final _name = TextEditingController();
  int _perSide = 7;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _ok {
    final n = _name.text.trim().length;
    return n >= 2 && n <= 40;
  }

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
            l.createTeam,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          MkLabel(l.teamName),
          TextField(
            controller: _name,
            autofocus: true,
            maxLength: 40,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
          MkLabel(l.gameSize),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final n in [5, 6, 7, 8, 11])
                ChoiceChip(
                  label: Text('${n}v$n'),
                  selected: _perSide == n,
                  onSelected: (_) => setState(() => _perSide = n),
                ),
            ],
          ),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: _ok
                ? () => Navigator.of(context).pop((_name.text.trim(), _perSide))
                : null,
            child: Text(l.createTeam),
          ),
        ],
      ),
    );
  }
}
