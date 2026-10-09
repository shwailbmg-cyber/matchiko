import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../domain/models/user_role.dart';
import '../l10n/gen/app_localizations.dart';
import '../ui/core/widgets/coming_soon.dart';
import '../ui/core/widgets/mk_nav_bar.dart';
import '../ui/features/auth/view_models/session_view_model.dart';
import '../ui/features/auth/views/login_screen.dart';
import '../ui/features/settings/views/settings_screen.dart';

abstract final class Routes {
  static const login = '/login';

  // Player area.
  static const home = '/home';
  static const play = '/play';
  static const matches = '/matches';
  static const profile = '/profile';
  static const settings = '/settings';

  // Manager area (a manager sees only these).
  static const mToday = '/m/today';
  static const mScan = '/m/scan';
  static const mPlayers = '/m/players';
  static const mSettings = '/m/settings';
}

/// Sends people to the area their server-side role allows. This is UX only:
/// the database refuses manager actions from players either way.
String? _redirect(SessionViewModel session, GoRouterState state) {
  final loc = state.matchedLocation;
  if (!session.signedIn) return loc == Routes.login ? null : Routes.login;
  final manager = session.role == UserRole.manager;
  final inManagerArea = loc.startsWith('/m/');
  if (loc == Routes.login || manager != inManagerArea) {
    return manager ? Routes.mToday : Routes.home;
  }
  return null;
}

GoRouter buildRouter(SessionViewModel session) {
  return GoRouter(
    initialLocation: Routes.home,
    refreshListenable: session,
    redirect: (_, state) => _redirect(session, state),
    routes: [
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      StatefulShellRoute.indexedStack(
        builder: (context, _, shell) => _Shell(shell: shell, manager: false),
        branches: [
          _branch(Routes.home, (l) => l.navHome, 'home'),
          _branch(Routes.play, (l) => l.navPlay, 'play'),
          _branch(Routes.matches, (l) => l.navMatches, 'matches'),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.profile,
                builder: (context, _) => ComingSoonScreen(
                  title: AppLocalizations.of(context).navProfile,
                  prototypeScreen: 'profile',
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      onPressed: () => context.push(Routes.settings),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, _, shell) => _Shell(shell: shell, manager: true),
        branches: [
          _branch(Routes.mToday, (l) => l.mgToday, 'mtoday'),
          _branch(Routes.mScan, (l) => l.mgScan, 'mscan'),
          _branch(Routes.mPlayers, (l) => l.mgPlayers, 'mplayers'),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: Routes.mSettings,
                builder: (_, _) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

StatefulShellBranch _branch(
  String path,
  String Function(AppLocalizations) title,
  String prototypeScreen,
) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, _) => ComingSoonScreen(
          title: title(AppLocalizations.of(context)),
          prototypeScreen: prototypeScreen,
        ),
      ),
    ],
  );
}

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
