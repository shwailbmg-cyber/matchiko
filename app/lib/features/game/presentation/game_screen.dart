import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/shared/widgets/ticket.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/providers.dart';

/// Game page (design canvas "Game page"): status, 10-hour check, line-up,
/// who's coming / who paid, share per player, booker tools, QR.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen(this.gameId, {super.key});

  final String gameId;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _busy = false;

  Future<void> _run(Future<void> Function(GameRepository repo) action) async {
    setState(() => _busy = true);
    try {
      await action(ref.read(gameRepositoryProvider));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(gameProvider(widget.gameId));
    final game = async.value;
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MkColors.bg,
        leading: IconButton(
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const BackButtonIcon(),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(Routes.matches),
        ),
        title: game == null ? null : StatusTag(game.status),
        centerTitle: true,
        actions: [
          if (game != null)
            IconButton(
              tooltip: l.shareGame,
              icon: const Icon(Icons.share_outlined),
              onPressed: () => _share(context, game),
            ),
        ],
      ),
      body: AsyncView(
        async,
        onRetry: () => ref.invalidate(gameProvider(widget.gameId)),
        data: (g) {
          final vm = _GameVm(g, busy: _busy, run: _run);
          final me = g.me;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
            children: [
              MkTitle(
                '${dayLabel(context, g.startsAt)} ${hhmm(g.startsAt)}',
                size: 40,
              ),
              const SizedBox(height: 6),
              Text(
                '${g.pitch.name(lang)} · ${g.perSide}v${g.perSide} · '
                '${g.competitive ? l.competitive : l.casual}',
                style: const TextStyle(color: MkColors.sub, fontSize: 14),
              ),
              if (vm.showStillComing) ...[
                const SizedBox(height: 16),
                _StillComing(vm),
              ],
              const SizedBox(height: 16),
              _LineUp(g),
              const SizedBox(height: 8),
              _TeamAverages(g),
              MkSection(
                l.whosComing,
                trailing: Text(
                  '${g.players.length} / ${g.capacity}',
                  style: const TextStyle(
                    fontFamily: MkFonts.display,
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: MkColors.primary,
                  ),
                ),
              ),
              _Players(vm),
              const SizedBox(height: 16),
              _Cost(g),
              const SizedBox(height: 16),
              if (g.iAmBooker) ...[
                _BookerTools(vm),
                const SizedBox(height: 16),
              ],
              if (vm.canJoin)
                FilledButton(
                  onPressed: vm.busy
                      ? null
                      : () => _pickPositionAndJoin(context, vm),
                  child: Text(l.join),
                )
              else if (me != null &&
                  g.status != BookingStatus.cancelled &&
                  g.status != BookingStatus.requested)
                FilledButton(
                  onPressed: () => showTicket(context, g),
                  child: Text(l.showQr),
                ),
              if (me != null && g.status == BookingStatus.requested)
                MkCard(child: StatusLadder(g.status)),
              if (g.iAmBooker &&
                  (g.status == BookingStatus.requested ||
                      g.status == BookingStatus.confirmed))
                TextButton(
                  onPressed: vm.busy ? null : () => _confirmCancel(context, vm),
                  child: Text(
                    l.cancelBooking,
                    style: const TextStyle(color: MkColors.red),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _share(BuildContext context, Game g) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    Clipboard.setData(
      ClipboardData(
        text:
            'Matchiko · ${g.pitch.name(lang)} · ${dayLabel(context, g.startsAt)} '
            '${hhmm(g.startsAt)} · ${g.perSide}v${g.perSide} · '
            '${l.spots(g.spotsLeft.toString())}\nhttps://matchiko.app/g/${g.id}',
      ),
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(l.linkCopied)));
  }

  Future<void> _pickPositionAndJoin(BuildContext context, _GameVm vm) async {
    final l = AppLocalizations.of(context);
    final pos = await showModalBottomSheet<Position>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l.joinAs,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            for (final p in Position.playable)
              ListTile(
                leading: Text(p.emoji, style: const TextStyle(fontSize: 22)),
                title: Text(positionName(l, p)),
                onTap: () => Navigator.of(ctx).pop(p),
              ),
          ],
        ),
      ),
    );
    if (pos != null) await vm.join(pos);
  }

  Future<void> _confirmCancel(BuildContext context, _GameVm vm) async {
    final l = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: MkColors.bg2,
        title: Text(l.cancelBooking),
        content: Text(l.cancelWarn),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l.keepBooking),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              l.cancelBooking,
              style: const TextStyle(color: MkColors.red),
            ),
          ),
        ],
      ),
    );
    if (ok ?? false) await vm.cancel();
  }
}

class _StillComing extends StatelessWidget {
  const _StillComing(this.vm);

  final _GameVm vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final left = vm.timeLeft;
    final confirmed = vm.game.me!.confirmed;
    final t =
        '${left.inHours} h ${(left.inMinutes % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: MkColors.sand.withValues(alpha: .1),
        border: Border.all(color: MkColors.sand.withValues(alpha: .35)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  confirmed ? l.youConfirmed : l.stillComing,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
              ),
              Text(
                l.gameIn(t),
                style: const TextStyle(
                  fontFamily: MkFonts.display,
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: MkColors.sand,
                ),
              ),
            ],
          ),
          if (!confirmed) ...[
            const SizedBox(height: 8),
            Text(
              l.stillComingSub,
              style: const TextStyle(color: Color(0xFFF1DCA4), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: vm.busy ? null : () => vm.coming(false),
                    child: Text(l.cantCome),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed: vm.busy ? null : () => vm.coming(true),
                    child: Text(l.yesComing),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _LineUp extends StatelessWidget {
  const _LineUp(this.game);

  final Game game;

  static const _x = {
    Position.gk: .06,
    Position.def: .2,
    Position.mid: .33,
    Position.fwd: .44,
    Position.ref: .5,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: PitchTurf(
        height: 220,
        radius: 18,
        child: LayoutBuilder(
          builder: (_, c) {
            final dots = <Widget>[];
            for (final team in Team.values) {
              final ps = game.players.where((p) => p.team == team).toList();
              final byPos = <Position, List<GamePlayer>>{};
              for (final p in ps) {
                (byPos[p.position] ??= []).add(p);
              }
              final color = team == Team.a ? MkColors.primary : MkColors.terra;
              byPos.forEach((pos, list) {
                for (var i = 0; i < list.length; i++) {
                  final p = list[i];
                  var x = _x[pos]! * c.maxWidth;
                  if (team == Team.b) x = c.maxWidth - x;
                  final y = (i + 1) / (list.length + 1) * c.maxHeight;
                  final r = p.isMe ? 15.0 : 13.0;
                  dots.add(
                    Positioned(
                      left: x - r,
                      top: y - r,
                      child: Container(
                        width: r * 2,
                        height: r * 2,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: p.isMe ? color : MkColors.bg,
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Text(
                          positionShort(l, pos),
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            color: p.isMe ? MkColors.ink : color,
                          ),
                        ),
                      ),
                    ),
                  );
                }
              });
            }
            return Stack(children: dots);
          },
        ),
      ),
    );
  }
}

class _TeamAverages extends StatelessWidget {
  const _TeamAverages(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final a = game.players.where((p) => p.team == Team.a).length;
    final b = game.players.length - a;
    const style = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w800,
      letterSpacing: .8,
    );
    return Row(
      children: [
        Text(
          '${l.yourTeam.toUpperCase()} · $a',
          style: style.copyWith(color: MkColors.primary),
        ),
        const Spacer(),
        Text(
          '${l.opponents.toUpperCase()} · $b',
          style: style.copyWith(color: MkColors.terra),
        ),
      ],
    );
  }
}

class _Players extends StatelessWidget {
  const _Players(this.vm);

  final _GameVm vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final g = vm.game;
    final share = g.share;
    return MkCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (final (i, p) in g.players.indexed)
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: MkColors.line)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  MkAvatar(p.initials, seed: i),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.isMe ? '${p.name} (${l.you})' : p.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          _note(l, p),
                          style: TextStyle(
                            fontSize: 12,
                            color: p.confirmed ? MkColors.sub : MkColors.sand,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _PaidChip(
                    player: p,
                    free: share.goalkeepersFree && p.position == Position.gk,
                    editable: g.iAmBooker && !p.isBooker,
                    onChanged: (v) => vm.setPaid(p.handle, v),
                  ),
                ],
              ),
            ),
          if (g.waitlist > 0)
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Text(
                    l.waitlistN(g.waitlist.toString()),
                    style: const TextStyle(color: MkColors.sub, fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _note(AppLocalizations l, GamePlayer p) {
    final parts = <String>[
      '${p.position.emoji} ${positionShort(l, p.position)}',
    ];
    if (p.guest) {
      parts.add(l.guestTag);
    } else if (!p.confirmed) {
      parts.add(l.notConfirmed);
    } else {
      parts.add(l.reliable(p.reliability.toString()));
    }
    if (p.isBooker) parts.add(l.booker);
    return parts.join(' · ');
  }
}

class _PaidChip extends StatelessWidget {
  const _PaidChip({
    required this.player,
    required this.free,
    required this.editable,
    required this.onChanged,
  });

  final GamePlayer player;
  final bool free;
  final bool editable;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    if (player.isBooker) return const SizedBox.shrink();
    final (text, color) = free
        ? (l.freeTag, MkColors.sub)
        : player.paid
        ? (l.paidTag, MkColors.primary)
        : (l.notPaid, MkColors.sand);
    final chip = MkTag(text, color: color);
    if (!editable || free) return chip;
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(!player.paid),
      child: Padding(padding: const EdgeInsets.all(4), child: chip),
    );
  }
}

class _Cost extends StatelessWidget {
  const _Cost(this.game);

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = game.share;
    final paid = game.players.where((p) => p.paid && !p.isBooker).length;
    return MkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.eachPays,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              Text(
                '${money(s.perPlayer)} ${l.da}',
                style: const TextStyle(
                  fontFamily: MkFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${l.pitch} ${money(game.pitch.priceDa)} ${l.da} · ${l.payersN(s.payers.toString())}'
            '${s.goalkeepersFree ? ' · ${l.gkFree}' : ''}',
            style: const TextStyle(color: MkColors.sub, fontSize: 13),
          ),
          if (game.iAmBooker && s.balance != 0) ...[
            const SizedBox(height: 4),
            Text(
              s.balance < 0
                  ? l.bookerAdds(money(-s.balance))
                  : l.bookerExtra(money(s.balance)),
              style: const TextStyle(color: MkColors.sand, fontSize: 13),
            ),
          ],
          if (game.iAmBooker) ...[
            const SizedBox(height: 4),
            Text(
              l.paidYou(paid.toString(), (game.players.length - 1).toString()),
              style: const TextStyle(color: MkColors.sub, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _BookerTools extends StatelessWidget {
  const _BookerTools(this.vm);

  final _GameVm vm;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final g = vm.game;
    return Column(
      children: [
        MkCard(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          child: SwitchListTile(
            value: g.open,
            onChanged: vm.busy ? null : vm.setOpen,
            title: Text(
              l.openToOthers,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              l.openToOthersSub,
              style: const TextStyle(color: MkColors.sub, fontSize: 12),
            ),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: vm.busy ? null : () => _resize(context),
            child: Text('${l.changeSize} · ${g.perSide}v${g.perSide}'),
          ),
        ),
      ],
    );
  }

  Future<void> _resize(BuildContext context) async {
    final l = AppLocalizations.of(context);
    final g = vm.game;
    final minSize = (g.players.length / 2).ceil().clamp(3, 11);
    final n = await showModalBottomSheet<int>(
      context: context,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l.changeSize,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (var i = minSize; i <= g.pitch.maxPerSide; i++)
                  ChoiceChip(
                    label: Text('${i}v$i'),
                    selected: g.perSide == i,
                    onSelected: (_) => Navigator.of(ctx).pop(i),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    if (n != null) await vm.setSize(n);
  }
}

/// Single game, refreshed when anything changes.
final gameProvider = FutureProvider.autoDispose.family<Game, String>(
  (ref, id) => watchGames(ref).game(id),
);

/// What the page's parts need: the game, a busy flag and the actions.
class _GameVm {
  _GameVm(this.game, {required this.busy, required this.run});

  final Game game;
  final bool busy;
  final Future<void> Function(Future<void> Function(GameRepository)) run;

  Duration get timeLeft => game.startsAt.difference(DateTime.now());

  /// The "Still coming?" box shows in the last 24 h for players in the game.
  bool get showStillComing =>
      game.me != null && timeLeft > Duration.zero && timeLeft.inHours < 24;

  bool get canJoin => game.me == null && game.open && !game.full;

  Future<void> join(Position p) => run((r) => r.joinGame(game.id, p));
  Future<void> coming(bool yes) =>
      run((r) => r.confirmComing(game.id, coming: yes));
  Future<void> setOpen(bool v) => run((r) => r.setOpen(game.id, open: v));
  Future<void> setPaid(String handle, bool v) =>
      run((r) => r.setPaid(game.id, handle, paid: v));
  Future<void> setSize(int n) => run((r) => r.setGameSize(game.id, n));
  Future<void> cancel() => run((r) => r.cancelBooking(game.id));
}
