abstract final class Routes {
  static const login = '/login';
  static const onboarding = '/welcome';

  // Player area (bottom nav).
  static const home = '/home';
  static const play = '/play';
  static const matches = '/matches';
  static const profile = '/profile';

  // Player screens pushed on top.
  static const settings = '/settings';
  static const notifications = '/notifications';
  static const wallet = '/wallet';
  static const editProfile = '/edit-profile';
  static const pitches = '/pitches';
  static String pitch(String id) => '/pitch/$id';
  static String game(String id) => '/game/$id';

  // Manager area (a manager sees only these).
  static const mToday = '/m/today';
  static const mScan = '/m/scan';
  static const mPlayers = '/m/players';
  static const mSettings = '/m/settings';
}
