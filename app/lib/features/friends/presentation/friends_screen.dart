import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/shared/widgets/friend_button.dart';

final _friendsProvider = FutureProvider.autoDispose<List<Player>>(
  (ref) => watchGames(ref).friends(),
);

final _searchProvider = FutureProvider.autoDispose.family<List<Player>, String>(
  (ref, q) => watchGames(ref).searchPlayers(q),
);

/// Friends: search by name or @handle, requests, friends, invite link.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final searching = _q.trim().isNotEmpty;
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.friendsTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          TextField(
            onChanged: (v) => setState(() => _q = v),
            decoration: InputDecoration(
              hintText: l.findPlayers,
              prefixIcon: const Icon(Icons.search, color: MkColors.faint),
            ),
          ),
          if (searching)
            ..._results(l)
          else ...[
            ..._lists(l),
            const SizedBox(height: 16),
            const _Invite(),
          ],
        ],
      ),
    );
  }

  List<Widget> _results(AppLocalizations l) {
    final list = ref.watch(_searchProvider(_q)).value;
    if (list == null) return const [];
    if (list.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: Center(
            child: Text(
              l.noPlayerFound,
              style: const TextStyle(color: MkColors.sub),
            ),
          ),
        ),
      ];
    }
    return [const SizedBox(height: 12), for (final p in list) _PlayerTile(p)];
  }

  List<Widget> _lists(AppLocalizations l) {
    final all = ref.watch(_friendsProvider).value ?? const <Player>[];
    List<Player> by(FriendStatus s) => all.where((p) => p.friend == s).toList();
    final incoming = by(FriendStatus.incoming);
    final friends = by(FriendStatus.friends);
    final sent = by(FriendStatus.sent);
    return [
      if (incoming.isNotEmpty) ...[
        MkLabel('${l.friendRequests} · ${incoming.length}'),
        for (final p in incoming) _PlayerTile(p),
      ],
      MkLabel('${l.friendsTitle} · ${friends.length}'),
      if (friends.isEmpty)
        Text(l.noFriends, style: const TextStyle(color: MkColors.sub)),
      for (final p in friends) _PlayerTile(p),
      if (sent.isNotEmpty) ...[
        MkLabel(l.sentRequests),
        for (final p in sent) _PlayerTile(p),
      ],
    ];
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile(this.p);

  final Player p;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: MkCard(
      padding: const EdgeInsets.all(12),
      onTap: () => context.push(Routes.player(p.handle)),
      child: Row(
        children: [
          MkAvatar(p.initials, size: 42, seed: p.name.length),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '@${p.handle} ',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: MkColors.sub,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    RankBadge(p.rank),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FriendButton(p, compact: true),
        ],
      ),
    ),
  );
}

class _Invite extends ConsumerWidget {
  const _Invite();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final handle = ref.watch(meProvider).value?.handle;
    return MkCard(
      onTap: handle == null
          ? null
          : () {
              Clipboard.setData(
                ClipboardData(text: 'https://matchiko.app/i/$handle'),
              );
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l.inviteCopied)));
            },
      child: Row(
        children: [
          const Text('🤝', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.invite,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  l.inviteSub,
                  style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                ),
              ],
            ),
          ),
          const Icon(Icons.copy, color: MkColors.sub, size: 18),
        ],
      ),
    );
  }
}
