import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/repositories/game_repository.dart';
import '../domain/models/user_role.dart';
import '../l10n/gen/app_localizations.dart';
import '../ui/core/widgets/mk_nav_bar.dart';
import '../ui/features/auth/view_models/session_view_model.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/game/view_models/game_view_model.dart';
import '../ui/features/game/views/game_screen.dart';
import '../ui/features/home/view_models/home_view_model.dart';
import '../ui/features/home/views/home_screen.dart';
import '../ui/features/manager/view_models/manager_view_models.dart';
import '../ui/features/manager/views/manager_screens.dart';
import '../ui/features/matches/view_models/matches_view_model.dart';
import '../ui/features/matches/views/matches_screen.dart';
import '../ui/features/notifications/views/notifications_screen.dart';
import '../ui/features/pitch/view_models/pitch_view_model.dart';
import '../ui/features/pitch/views/pitch_screen.dart';
import '../ui/features/play/view_models/play_view_model.dart';
import '../ui/features/play/views/play_screen.dart';
import '../ui/features/profile/view_models/profile_view_model.dart';
import '../ui/features/profile/views/profile_screen.dart';
import '../ui/features/settings/views/settings_screen.dart';
import 'routes.dart';

export 'routes.dart';

/// Sends people to the area their server-side role allows. This is UX only:
/// the database refuses manager actions from players either way.
String? _redirect(SessionViewModel session, GoRouterState state) {
  final loc = state.matchedLocation;
  if (!session.signedIn) return loc == Routes.login ? null : Routes.login;
  final manager = session.role == UserRole.manager;
  final inManagerArea = loc.startsWith('/m/');
  final shared = loc == Routes.settings || loc == Routes.notifications;
  if (loc == Routes.login || (!shared && manager != inManagerArea)) {
    return manager ? Routes.mToday : Routes.home;
  }
  return null;
}

/// Wraps a screen with its view model, created from the repository and
/// loaded right away.
Widget _with<T extends ChangeNotifier>(
  T Function(GameRepository repo) create,
  Widget child, {
  void Function(T vm)? init,
}) => ChangeNotifierProvider<T>(
  create: (ctx) {
    final vm = create(ctx.read<GameRepository>());
    init?.call(vm);
    return vm;
  },
  child: child,
);

GoRouter buildRouter(SessionViewModel session) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: session,
    redirect: (_, state) => _redirect(session, state),
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(
        path: Routes.notifications,
        builder: (_, _) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/pitch/:id',
        builder: (_, s) => _with(
          (r) => PitchViewModel(r, s.pathParameters['id']!),
          const PitchScreen(),
          init: (vm) => vm.load(),
        ),
      ),
      GoRoute(
        path: '/game/:id',
        builder: (_, s) => _with(
          (r) => GameViewModel(r, s.pathParameters['id']!),
          const GameScreen(),
          init: (vm) => vm.load(),
        ),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, _, shell) => _Shell(shell: shell, manager: false),
        branches: [
          _branch(
            Routes.home,
            (_) => _with(
              HomeViewModel.new,
              const HomeScreen(),
              init: (vm) => vm.load(),
            ),
          ),
          _branch(
            Routes.play,
            (_) => _with(PlayViewModel.new, const PlayScreen()),
          ),
          _branch(
            Routes.matches,
            (_) => _with(
              MatchesViewModel.new,
              const MatchesScreen(),
              init: (vm) => vm.load(),
            ),
          ),
          _branch(
            Routes.profile,
            (_) => _with(
              ProfileViewModel.new,
              const ProfileScreen(),
              init: (vm) => vm.load(),
            ),
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, _, shell) => _Shell(shell: shell, manager: true),
        branches: [
          _branch(
            Routes.mToday,
            (_) => _with(
              TodayViewModel.new,
              const TodayScreen(),
              init: (vm) => vm.load(),
            ),
          ),
          _branch(
            Routes.mScan,
            (_) => _with(
              ScanViewModel.new,
              const ScanScreen(),
              init: (vm) => vm.load(),
            ),
          ),
          _branch(
            Routes.mPlayers,
            (_) => _with(
              PlayersViewModel.new,
              const PlayersScreen(),
              init: (vm) => vm.load(),
            ),
          ),
          _branch(Routes.mSettings, (_) => const SettingsScreen()),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(String path, WidgetBuilder builder) =>
    StatefulShellBranch(
      routes: [GoRoute(path: path, builder: (context, _) => builder(context))],
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
