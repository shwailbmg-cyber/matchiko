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
  static const privacy = '/privacy';
  static const pitches = '/pitches';
  static const friends = '/friends';
  static const teams = '/teams';
  static const referee = '/referee';
  static String matchReport(String gameId) => '/referee/report/$gameId';
  static String team(String id) => '/team/$id';
  static String player(String handle, {String? game}) =>
      '/player/$handle${game == null ? '' : '?game=$game'}';
  static String pitch(String id) => '/pitch/$id';
  static String game(String id) => '/game/$id';

  // Manager area (a manager sees only these).
  static const mToday = '/m/today';
  static const mScan = '/m/scan';
  static const mPlayers = '/m/players';
  static const mCalendar = '/m/calendar';
  static const mVenue = '/m/venue';
  static const mReports = '/m/reports';
}
