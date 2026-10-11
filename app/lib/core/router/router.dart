import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/widgets/mk_nav_bar.dart';
import 'package:matchiko/features/auth/presentation/login_screen.dart';
import 'package:matchiko/features/friends/presentation/friends_screen.dart';
import 'package:matchiko/features/game/presentation/game_screen.dart';
import 'package:matchiko/features/home/presentation/home_screen.dart';
import 'package:matchiko/features/manager/presentation/players_screen.dart';
import 'package:matchiko/features/manager/presentation/scan_screen.dart';
import 'package:matchiko/features/manager/presentation/today_screen.dart';
import 'package:matchiko/features/matches/presentation/matches_screen.dart';
import 'package:matchiko/features/notifications/presentation/notifications_screen.dart';
import 'package:matchiko/features/pitch/presentation/pitch_screen.dart';
import 'package:matchiko/features/pitches/presentation/pitches_screen.dart';
import 'package:matchiko/features/play/presentation/play_screen.dart';
import 'package:matchiko/features/player/presentation/player_screen.dart';
import 'package:matchiko/features/profile/presentation/profile_form_screen.dart';
import 'package:matchiko/features/profile/presentation/profile_screen.dart';
import 'package:matchiko/features/referee/presentation/match_report_screen.dart';
import 'package:matchiko/features/referee/presentation/referee_screen.dart';
import 'package:matchiko/features/settings/presentation/settings_screen.dart';
import 'package:matchiko/features/teams/presentation/team_screen.dart';
import 'package:matchiko/features/teams/presentation/teams_screen.dart';
import 'package:matchiko/features/wallet/presentation/wallet_screen.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/user_role.dart';
import 'package:matchiko/shared/providers.dart';

export 'package:matchiko/core/router/routes.dart';

/// Sends people to the area their server-side role allows. This is UX only:
/// the database refuses manager actions from players either way.
/// Players with an unfinished profile go to onboarding first.
String? _redirect(SessionUser? user, Profile? me, GoRouterState state) {
  final loc = state.matchedLocation;
  if (user == null) return loc == Routes.login ? null : Routes.login;
  final manager = user.role == UserRole.manager;
  if (!manager && me != null) {
    final welcome = loc == Routes.onboarding;
    if (!me.onboarded && !welcome) return Routes.onboarding;
    if (me.onboarded && welcome) return Routes.home;
  }
  final inManagerArea = loc.startsWith('/m/');
  final shared = loc == Routes.settings || loc == Routes.notifications;
  if (loc == Routes.login || (!shared && manager != inManagerArea)) {
    return manager ? Routes.mToday : Routes.home;
  }
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final refresh = ValueNotifier(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.listen(meProvider, (_, _) => refresh.value++);
  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: refresh,
    redirect: (_, state) =>
        _redirect(auth.currentUser, ref.read(meProvider).value, state),
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: Routes.onboarding,
        builder: (_, _) => const ProfileFormScreen(onboarding: true),
      ),
      GoRoute(
        path: Routes.editProfile,
        builder: (_, _) => const ProfileFormScreen(onboarding: false),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(path: Routes.pitches, builder: (_, _) => const PitchesScreen()),
      GoRoute(path: Routes.wallet, builder: (_, _) => const WalletScreen()),
      GoRoute(path: Routes.friends, builder: (_, _) => const FriendsScreen()),
      GoRoute(path: Routes.teams, builder: (_, _) => const TeamsScreen()),
      GoRoute(path: Routes.referee, builder: (_, _) => const RefereeScreen()),
      GoRoute(
        path: '/referee/report/:id',
        builder: (_, s) => MatchReportScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/team/:id',
        builder: (_, s) => TeamScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/player/:handle',
        builder: (_, s) => PlayerScreen(
          s.pathParameters['handle']!,
          gameId: s.uri.queryParameters['game'],
        ),
      ),
      GoRoute(
        path: '/pitch/:id',
        builder: (_, s) => PitchScreen(s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/game/:id',
        builder: (_, s) => GameScreen(s.pathParameters['id']!),
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _Shell(shell: shell, manager: false),
        branches: [
          _branch(Routes.home, const HomeScreen()),
          _branch(Routes.play, const PlayScreen()),
          _branch(Routes.matches, const MatchesScreen()),
          _branch(Routes.profile, const ProfileScreen()),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => _Shell(shell: shell, manager: true),
        branches: [
          _branch(Routes.mToday, const TodayScreen()),
          _branch(Routes.mScan, const ScanScreen()),
          _branch(Routes.mPlayers, const PlayersScreen()),
          _branch(Routes.mSettings, const SettingsScreen()),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (_, _) => screen)],
);

class _Shell extends StatelessWidget {
  const _Shell({required this.shell, required this.manager});

  final StatefulNavigationShell shell;
  final bool manager;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final items = manager
        ? [
            MkNavItem(Icons.calendar_today_outlined, l.mgToday),
            MkNavItem(Icons.qr_code_scanner, l.mgScan),
            MkNavItem(Icons.groups_outlined, l.mgPlayers),
            MkNavItem(Icons.settings_outlined, l.mgSettings),
          ]
        : [
            MkNavItem(Icons.home_outlined, l.navHome),
            MkNavItem(Icons.bolt, l.navPlay, diamond: true),
            MkNavItem(Icons.calendar_today_outlined, l.navMatches),
            MkNavItem(Icons.person_outline, l.navProfile),
          ];
    return Scaffold(
      body: shell,
      bottomNavigationBar: MkNavBar(
        items: items,
        current: shell.currentIndex,
        onTap: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
      ),
    );
  }
}
