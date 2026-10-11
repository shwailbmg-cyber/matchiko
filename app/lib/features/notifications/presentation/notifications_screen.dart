import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/providers.dart';

/// Notifications center.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  late final GameRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = ref.read(gameRepositoryProvider);
  }

  /// Unread dots stay while the list is open; leaving marks all read.
  @override
  void dispose() {
    _repo.markNotificationsRead();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.notifs)),
      body: AsyncView(
        ref.watch(notificationsProvider),
        onRetry: () => ref.invalidate(notificationsProvider),
        data: (list) => list.isEmpty
            ? Center(
                child: Text(
                  l.noNotifs,
                  style: const TextStyle(color: MkColors.sub),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: list.length,
                itemBuilder: (_, i) => _Item(list[i]),
              ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item(this.n);

  final AppNotification n;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final (mark, color, title, body) = switch (n.kind) {
      NotificationKind.stillComing => (
        '?',
        MkColors.sand,
        l.nStillTitle,
        l.nStillBody(n.text('time')),
      ),
      NotificationKind.spotOpen => (
        '+',
        MkColors.primary,
        l.nSpotTitle,
        l.nSpotBody(n.text('pitch'), n.text('time')),
      ),
      NotificationKind.bookingConfirmed => (
        '✓',
        MkColors.blue,
        l.nConfTitle,
        l.nConfBody,
      ),
      NotificationKind.rateGame => (
        '★',
        MkColors.sand,
        l.nRateTitle,
        l.nRateBody,
      ),
      NotificationKind.friendRequest => (
        '🤝',
        MkColors.primary,
        l.nFriendTitle,
        l.nFriendBody(n.text('name')),
      ),
      NotificationKind.other => ('•', MkColors.sub, l.notifs, ''),
    };
    final gameId = n.text('game_id');
    final target = switch (n.kind) {
      NotificationKind.friendRequest => Routes.friends,
      NotificationKind.rateGame => Routes.matches,
      _ when gameId.isNotEmpty => Routes.game(gameId),
      _ => null,
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: MkCard(
        padding: const EdgeInsets.all(14),
        borderColor: n.unread ? MkColors.primary.withValues(alpha: .5) : null,
        onTap: target == null ? null : () => context.push(target),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: color.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Text(
                mark,
                style: TextStyle(color: color, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  if (body.isNotEmpty)
                    Text(
                      body,
                      style: const TextStyle(
                        color: MkColors.sub,
                        fontSize: 12.5,
                      ),
                    ),
                  Text(
                    '${dayLabel(context, n.createdAt)} · ${hhmm(n.createdAt)}',
                    style: const TextStyle(color: MkColors.faint, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (n.unread)
              const Padding(
                padding: EdgeInsetsDirectional.only(start: 8, top: 4),
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: MkColors.primary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
