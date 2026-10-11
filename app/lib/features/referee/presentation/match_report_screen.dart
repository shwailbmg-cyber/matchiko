import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/referee.dart';
import 'package:matchiko/shared/providers.dart';

final _gameProvider = FutureProvider.autoDispose.family<Game, String>(
  (ref, id) => watchGames(ref).game(id),
);

const _icons = {
  MatchEventType.goal: '⚽',
  MatchEventType.yellow: '🟨',
  MatchEventType.red: '🟥',
  MatchEventType.mvp: '⭐',
};

/// `SC.reflog`: the referee logs goals, cards and the MVP, then submits.
/// The server checks every player is in that team and pays the rewards.
class MatchReportScreen extends ConsumerStatefulWidget {
  const MatchReportScreen(this.gameId, {super.key});

  final String gameId;

  @override
  ConsumerState<MatchReportScreen> createState() => _MatchReportState();
}

class _MatchReportState extends ConsumerState<MatchReportScreen> {
  final _events = <MatchEvent>[];
  bool _sending = false;

  int _goals(Side s) =>
      _events.where((e) => e.side == s && e.type == MatchEventType.goal).length;

  void _add(GamePlayer p, MatchEventType type) => setState(() {
    if (type == MatchEventType.mvp) {
      _events.removeWhere((e) => e.type == MatchEventType.mvp);
    }
    _events.add(MatchEvent(type: type, side: p.team, handle: p.handle));
  });

  void _undo(GamePlayer p) => setState(() {
    final i = _events.lastIndexWhere((e) => e.handle == p.handle);
    if (i >= 0) _events.removeAt(i);
  });

  Future<void> _submit() async {
    final l = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _sending = true);
    try {
      await ref
          .read(gameRepositoryProvider)
          .submitMatchReport(widget.gameId, _events);
      messenger.showSnackBar(SnackBar(content: Text(l.reported)));
      router.pop();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(l.genericError)));
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _pick(GamePlayer p) async {
    final l = AppLocalizations.of(context);
    final names = {
      MatchEventType.goal: l.goal,
      MatchEventType.yellow: l.yellow,
      MatchEventType.red: l.red,
      MatchEventType.mvp: l.mvp,
    };
    await showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(
                p.name,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            for (final t in MatchEventType.values)
              ListTile(
                leading: Text(_icons[t]!, style: const TextStyle(fontSize: 22)),
                title: Text(names[t]!),
                onTap: () {
                  Navigator.of(ctx).pop();
                  _add(p, t);
                },
              ),
            ListTile(
              leading: const Icon(Icons.undo),
              title: Text(l.undo),
              onTap: () {
                Navigator.of(ctx).pop();
                _undo(p);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.refLog)),
      body: AsyncView(
        ref.watch(_gameProvider(widget.gameId)),
        onRetry: () => ref.invalidate(_gameProvider(widget.gameId)),
        data: (g) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(MkRadius.card),
                gradient: const LinearGradient(
                  colors: [MkColors.heroViolet, MkColors.heroDeep],
                ),
              ),
              child: Zellij(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  child: Text(
                    'A   ${_goals(Side.a)} – ${_goals(Side.b)}   B',
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(
                      fontFamily: MkFonts.display,
                      fontSize: 44,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(l.refTapPlayer, style: const TextStyle(color: MkColors.sub)),
            for (final side in Side.values) ...[
              MkLabel(side == Side.a ? 'A' : 'B'),
              for (final p in g.players.where((p) => p.team == side))
                _Row(
                  p,
                  marks: _events
                      .where((e) => e.handle == p.handle)
                      .map((e) => _icons[e.type]!)
                      .join(),
                  onTap: () => _pick(p),
                ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _sending ? null : _submit,
              child: Text(l.submitReport),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.p, {required this.marks, required this.onTap});

  final GamePlayer p;
  final String marks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: MkCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      onTap: onTap,
      child: Row(
        children: [
          MkAvatar(p.initials, size: 30, seed: p.name.length),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              p.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Text(marks, style: const TextStyle(fontSize: 16)),
        ],
      ),
    ),
  );
}
