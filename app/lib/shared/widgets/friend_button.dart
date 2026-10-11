import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/providers.dart';

/// Add / cancel / accept / remove, depending on my friendship with [player].
class FriendButton extends ConsumerWidget {
  const FriendButton(this.player, {super.key, this.compact = false});

  final Player player;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repo = ref.read(gameRepositoryProvider);
    final h = player.handle;
    if (compact) {
      return _icons(l, repo.addFriend, repo.acceptFriend, repo.removeFriend);
    }
    const size = Size.fromHeight(48);
    return switch (player.friend) {
      FriendStatus.none => FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: size),
        onPressed: () => repo.addFriend(h),
        icon: const Icon(Icons.person_add_alt_1, size: 18),
        label: Text(l.addFriend),
      ),
      FriendStatus.sent => OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: size),
        onPressed: () => repo.removeFriend(h),
        child: Text(l.requestSent),
      ),
      FriendStatus.incoming => Row(
        children: [
          Flexible(
            child: FilledButton(
              style: FilledButton.styleFrom(minimumSize: size),
              onPressed: () => repo.acceptFriend(h),
              child: Text(l.acceptFriend),
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
            style: OutlinedButton.styleFrom(minimumSize: size),
            onPressed: () => repo.removeFriend(h),
            child: Text(l.decline),
          ),
        ],
      ),
      FriendStatus.friends => OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          minimumSize: size,
          foregroundColor: MkColors.primary,
        ),
        onPressed: () => repo.removeFriend(h),
        icon: const Icon(Icons.check, size: 18),
        label: Text(l.friendsTag),
      ),
    };
  }

  /// Small icon buttons for list rows.
  Widget _icons(
    AppLocalizations l,
    Future<void> Function(String) add,
    Future<void> Function(String) accept,
    Future<void> Function(String) remove,
  ) {
    final h = player.handle;
    return switch (player.friend) {
      FriendStatus.none => IconButton.filled(
        tooltip: l.addFriend,
        onPressed: () => add(h),
        icon: const Icon(Icons.person_add_alt_1, size: 20),
      ),
      FriendStatus.sent => IconButton.outlined(
        tooltip: l.requestSent,
        onPressed: () => remove(h),
        icon: const Icon(Icons.schedule_send, size: 20),
      ),
      FriendStatus.incoming => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton.filled(
            tooltip: l.acceptFriend,
            onPressed: () => accept(h),
            icon: const Icon(Icons.check, size: 20),
          ),
          IconButton.outlined(
            tooltip: l.decline,
            onPressed: () => remove(h),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
      FriendStatus.friends => IconButton(
        tooltip: l.friendsTag,
        onPressed: null,
        icon: const Icon(Icons.how_to_reg, color: MkColors.primary),
      ),
    };
  }
}
