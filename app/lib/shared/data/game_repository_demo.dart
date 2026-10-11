import 'dart:async';

import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/calendar_entry.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/ledger_entry.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/referee.dart';
import 'package:matchiko/shared/domain/team.dart';
import 'package:matchiko/shared/domain/venue.dart';
import 'package:matchiko/shared/domain/venue_review.dart';
import 'package:matchiko/shared/domain/game_repository.dart';

/// In-memory sample data, same as the Claude Design prototype. Used when the
/// app is built without Supabase config (demo builds, tests).
class DemoGameRepository implements GameRepository {
  /// [onboarded] false starts with an unfinished profile, so testers see
  /// the onboarding after the first sign-in.
  DemoGameRepository({
    DateTime Function()? clock,
    this.latency = Duration.zero,
    bool onboarded = true,
  }) : _clock = clock ?? DateTime.now {
    _seed();
    if (!onboarded) {
      _me = _me.copyWith(wilayaId: null, level: null, phone: null);
    }
  }

  final DateTime Function() _clock;

  /// Fake network delay so loading states show in demos.
  final Duration latency;

  late Profile _me;
  final _pitches = <Pitch>[];
  final _games = <String, Game>{};
  final _past = <Game>[];
  final _queue = <Profile>[];
  final _taken = <String>{};
  final _favorites = <String>{'harrach'};
  final _ledger = <LedgerEntry>[];
  final _people = <String, Player>{};
  final _notifs = <AppNotification>[];
  final _teams = <String, Team>{};
  late RefereeStatus _refStatus = _me.isReferee
      ? RefereeStatus.approved
      : RefereeStatus.none;
  final _availability = <int, RefAvailability>{
    5: const RefAvailability(weekday: 5, startHour: 18, endHour: 23),
  };
  final _jobs = <String, RefJob>{};

  /// Blocks and walk-ins at the manager's venue (`pitch_blocks`).
  final _blocks = <String, (String pitchId, CalendarEntry entry)>{};
  final _refApps = <RefApplication>[];
  final _venueReports = <VenueReport>[];
  var _venue = const Venue(
    id: 'v-harrach',
    name: 'Complexe El Harrach',
    openHour: 8,
    closeHour: 24,
  );

  /// Reports sent from this device (the demo has no review queue yet).
  final reports = <(String, ReportReason)>[];
  int _seq = 100;

  final _changes = StreamController<int>.broadcast();
  int _revision = 0;

  @override
  Stream<int> get changes => _changes.stream;

  void _changed() => _changes.add(++_revision);

  DateTime _at(int dayOffset, int hour) {
    final n = _clock();
    return DateTime(n.year, n.month, n.day + dayOffset, hour);
  }

  static GamePlayer _p(
    String name,
    Position pos,
    Side team, {
    int rel = 95,
    bool paid = false,
    bool confirmed = true,
    bool guest = false,
  }) => GamePlayer(
    name: name,
    handle: name
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll(RegExp('[^a-z0-9_]'), ''),
    position: pos,
    team: team,
    reliability: rel,
    paid: paid,
    confirmed: confirmed,
    guest: guest,
  );

  GamePlayer get _meAsPlayer => GamePlayer(
    name: _me.name,
    handle: _me.handle,
    position: _me.positions.first,
    team: Side.a,
    reliability: _me.reliability,
    isMe: true,
  );

  void _seed() {
    _me = const Profile(
      name: 'Amine Benali',
      handle: 'amineb7',
      xp: 1240,
      coins: 340,
      verified: true,
      positions: [Position.mid, Position.fwd],
      reliability: 94,
      played: 47,
      wins: 28,
      goals: 31,
      isReferee: true,
      wilayaId: 'alger',
      level: Level.good,
      phone: '+213555123456',
    );
    for (final (d, r, xp, c) in [
      (12, RewardReason.verified, 100, 200),
      (9, RewardReason.showUp, 30, 20),
      (9, RewardReason.win, 15, 30),
      (6, RewardReason.showUp, 30, 20),
      (6, RewardReason.goal, 10, 30),
      (5, RewardReason.rateGame, 5, 10),
      (2, RewardReason.showUp, 30, 20),
      (2, RewardReason.mvp, 25, 30),
    ]) {
      _earn(r, xp, c, _at(-d, 22));
    }
    _seedPeople();
    _seedNotifications();
    _pitches.addAll(const [
      Pitch(
        id: 'harrach',
        venue: 'Complexe El Harrach',
        venueAr: 'مركب الحراش',
        district: 'El Harrach, Alger',
        km: .8,
        rating: 4.7,
        reviews: 143,
        maxPerSide: 7,
        priceDa: 2500,
        features: {Feature.light, Feature.ball, Feature.roof},
      ),
      Pitch(
        id: 'biar',
        venue: 'Terrain El Biar',
        venueAr: 'ملعب الأبيار',
        district: 'El Biar, Alger',
        km: 1.4,
        rating: 4.3,
        reviews: 89,
        maxPerSide: 11,
        priceDa: 3000,
        features: {Feature.light, Feature.shower, Feature.ref},
      ),
      Pitch(
        id: 'kouba',
        venue: 'Kouba Five',
        venueAr: 'ملعب القبة',
        district: 'Kouba, Alger',
        km: 2.1,
        rating: 4.9,
        reviews: 201,
        maxPerSide: 5,
        priceDa: 2000,
        features: {Feature.light, Feature.ball, Feature.shower, Feature.roof},
      ),
    ]);
    final harrach = _pitches[0], biar = _pitches[1], kouba = _pitches[2];

    // My game tonight: I'm the booker.
    final mine = [
      _meAsPlayer.copyWith(paid: true),
      _p('Yacine Kaci', Position.mid, Side.a, rel: 97, paid: true),
      _p('Hakim Mansouri', Position.def, Side.a, rel: 91, paid: true),
      _p('Bilal Tahar', Position.gk, Side.a, rel: 99),
      _p('Walid Djebbar', Position.def, Side.a, rel: 78, confirmed: false),
      _p('Karim', Position.fwd, Side.a, guest: true),
      _p('Redha Khelifi', Position.gk, Side.b, rel: 93, paid: true),
      _p('Karim Bouzid', Position.def, Side.b, rel: 88, paid: true),
      _p('Nassim Hadj', Position.def, Side.b, rel: 95),
      _p('Omar Saidi', Position.mid, Side.b, rel: 90, paid: true),
      _p('Raouf Ghali', Position.mid, Side.b, rel: 96, paid: true),
      _p('Ilyes Meziane', Position.fwd, Side.b, rel: 92),
    ];
    _add(
      Game(
        id: 'g1',
        pitch: harrach,
        startsAt: _at(0, 21),
        perSide: 7,
        status: BookingStatus.confirmed,
        players: [
          GamePlayer(
            name: mine.first.name,
            handle: mine.first.handle,
            position: mine.first.position,
            team: Side.a,
            reliability: mine.first.reliability,
            paid: true,
            isMe: true,
            isBooker: true,
          ),
          ...mine.skip(1),
        ],
        open: true,
        waitlist: 2,
        code: 'MTK-3A-2100',
      ),
    );
    _add(
      Game(
        id: 'g2',
        pitch: biar,
        startsAt: _at(2, 19),
        perSide: 8,
        status: BookingStatus.requested,
        players: [_meAsPlayer],
        code: 'MTK-10B-1900',
      ),
    );
    // Open games near me.
    _add(
      Game(
        id: 'o1',
        pitch: harrach,
        startsAt: _at(0, 20),
        perSide: 6,
        status: BookingStatus.guaranteed,
        open: true,
        players: _filler(9),
        code: 'MTK-3A-2000',
      ),
    );
    _add(
      Game(
        id: 'o2',
        pitch: kouba,
        startsAt: _at(0, 22),
        perSide: 5,
        status: BookingStatus.confirmed,
        open: true,
        players: _filler(9),
        code: 'MTK-17C-2200',
      ),
    );
    _add(
      Game(
        id: 'o3',
        pitch: biar,
        startsAt: _at(1, 21),
        perSide: 8,
        status: BookingStatus.confirmed,
        open: true,
        competitive: true,
        players: _filler(11),
        code: 'MTK-10B-2100',
      ),
    );
    // Today at El Harrach (manager view).
    _add(
      _venueGame('v1', harrach, 18, BookingStatus.requested, 'Riad Mansouri'),
    );
    _add(
      _venueGame('v2', harrach, 19, BookingStatus.confirmed, 'Nabil Ferhat'),
    );
    _add(
      _venueGame('v3', harrach, 20, BookingStatus.guaranteed, 'Samy Lounis'),
    );
    _add(_venueGame('v4', harrach, 22, BookingStatus.requested, 'Farid Ouali'));

    _past.addAll([
      Game(
        id: 'p1',
        pitch: kouba,
        startsAt: _at(-3, 20),
        perSide: 5,
        status: BookingStatus.completed,
        players: [_meAsPlayer],
      ),
      Game(
        id: 'p2',
        pitch: harrach,
        startsAt: _at(-6, 21),
        perSide: 6,
        status: BookingStatus.completed,
        players: [_meAsPlayer],
      ),
    ]);
    _queue.addAll(const [
      Profile(
        name: 'Omar Belkacem',
        handle: 'omar_b',
        xp: 320,
        coins: 0,
        verified: false,
        positions: [Position.def],
        reliability: 100,
        played: 3,
        wins: 1,
        goals: 0,
      ),
      Profile(
        name: 'Ilyes Kaci',
        handle: 'ilyes_k',
        xp: 0,
        coins: 0,
        verified: false,
        positions: [Position.fwd],
        reliability: 100,
        played: 0,
        wins: 0,
        goals: 0,
      ),
    ]);
    _seedTeams();
    _seedJobs();
    _seedReviews();
    _blocks['b1'] = (
      'harrach',
      CalendarEntry(
        id: 'b1',
        startsAt: _at(1, 18),
        kind: CalendarKind.blocked,
        label: 'Maintenance',
      ),
    );
    _blocks['w1'] = (
      'harrach',
      CalendarEntry(
        id: 'w1',
        startsAt: _at(1, 20),
        kind: CalendarKind.walkIn,
        label: 'Karim (téléphone)',
        phone: '+213555000111',
      ),
    );
  }

  static const _names = [
    'Samy Lounis',
    'Adel Zitouni',
    'Riad Mansouri',
    'Nabil Ferhat',
    'Farid Ouali',
    'Mehdi Saadi',
    'Anis Rahmani',
    'Sofiane Amrani',
    'Walid Djebbar',
    'Chouaib Benali',
    'Raouf Ghali',
  ];

  /// Sample players with unique names (and so unique handles).
  List<GamePlayer> _filler(int n) => [
    for (var i = 0; i < n; i++)
      _p(
        i < _names.length
            ? _names[i]
            : '${_names[i % _names.length].split(' ').first} '
                  '${const ['Haddad', 'Belkacem', 'Ziani'][i ~/ _names.length - 1]}',
        Position.playable[(i ~/ 2) % 4],
        i.isEven ? Side.a : Side.b,
        rel: 85 + (i * 7) % 15,
        paid: i % 3 != 0,
      ),
  ];

  Game _venueGame(String id, Pitch p, int h, BookingStatus st, String booker) =>
      Game(
        id: id,
        pitch: p,
        startsAt: _at(0, h),
        perSide: 7,
        status: st,
        players: [
          GamePlayer(
            name: booker,
            handle: booker.toLowerCase().replaceAll(' ', '_'),
            position: Position.mid,
            team: Side.a,
            isBooker: true,
          ),
          ..._filler(10).where((p) => p.name != booker).take(9),
        ],
        code: 'MTK-$id'.toUpperCase(),
      );

  void _add(Game g) {
    _games[g.id] = g;
    _taken.add(_slotKey(g.pitch.id, g.startsAt));
  }

  static String _slotKey(String pitchId, DateTime t) =>
      '$pitchId-${t.year}-${t.month}-${t.day}-${t.hour}';

  Future<T> _wait<T>(T Function() f) async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return f();
  }

  void _update(String id, Game Function(Game) f) {
    final g = _games[id];
    if (g == null) throw StateError('unknown game $id');
    _games[id] = f(g);
    _changed();
  }

  // ── Player ───────────────────────────────────────────────────────────

  @override
  Future<Profile> me() => _wait(() => _me);

  void _seedPeople() {
    const wilayas = ['alger', 'blida', 'boumerdes', 'tipaza', 'alger', 'oran'];
    for (final (i, name) in _names.indexed) {
      final handle = name.toLowerCase().replaceAll(' ', '_');
      _people[handle] = Player(
        handle: handle,
        name: name,
        wilayaId: wilayas[i % wilayas.length],
        positions: [Position.playable[(i ~/ 2) % 4]],
        xp: 200 + i * 173 % 2400,
        verified: i % 3 != 2,
        played: 5 + i * 7 % 60,
        friend: switch (i) {
          0 || 1 || 3 => FriendStatus.friends,
          4 => FriendStatus.incoming,
          6 => FriendStatus.sent,
          _ => FriendStatus.none,
        },
      );
    }
  }

  /// Directory entry, or one built from a line-up so every row opens.
  Player _person(String handle) {
    final known = _people[handle];
    if (known != null) return known;
    final gp = [..._games.values, ..._past]
        .expand((g) => g.players)
        .where((p) => p.handle == handle && !p.guest)
        .firstOrNull;
    if (gp == null) throw StateError('no player @$handle');
    return _people[handle] = Player(
      handle: handle,
      name: gp.name,
      positions: [gp.position],
      xp: 300 + handle.length * 97,
      verified: true,
      played: 10 + handle.length,
    );
  }

  void _setFriend(String handle, FriendStatus s) {
    _people[handle] = _person(handle).copyWith(friend: s);
    _changed();
  }

  @override
  Future<List<Player>> searchPlayers(String query) => _wait(() {
    final q = query.trim().toLowerCase().replaceFirst('@', '');
    if (q.isEmpty) return <Player>[];
    return _people.values
        .where((p) => p.handle.contains(q) || p.name.toLowerCase().contains(q))
        .toList();
  });

  @override
  Future<Player> player(String handle) => _wait(() => _person(handle));

  @override
  Future<List<Player>> friends() => _wait(
    () => _people.values.where((p) => p.friend != FriendStatus.none).toList(),
  );

  @override
  Future<void> addFriend(String handle) =>
      _wait(() => _setFriend(handle, FriendStatus.sent));

  @override
  Future<void> acceptFriend(String handle) => _wait(() {
    if (_person(handle).friend == FriendStatus.incoming) {
      _setFriend(handle, FriendStatus.friends);
    }
  });

  @override
  Future<void> removeFriend(String handle) =>
      _wait(() => _setFriend(handle, FriendStatus.none));

  void _seedJobs() {
    // The game I refereed yesterday (not one of my games as a player).
    _add(
      Game(
        id: 'r1',
        pitch: _pitches[2],
        startsAt: _at(-1, 21),
        perSide: 5,
        status: BookingStatus.guaranteed,
        players: _filler(10),
      ),
    );
    for (final (id, d, h, venue, n, mine, reported, game) in [
      ('j1', 1, 20, 'Complexe El Harrach', 7, false, false, null),
      ('j2', 2, 21, 'Stade Biar', 11, false, false, null),
      ('j3', 3, 19, 'Kouba Five', 5, false, false, null),
      ('j4', 4, 22, 'Complexe El Harrach', 7, true, false, null),
      ('j5', -1, 21, 'Kouba Five', 5, true, false, 'r1'),
      ('j6', -6, 20, 'Kouba Five', 5, true, true, 'p2'),
    ]) {
      _jobs[id] = RefJob(
        bookingId: id,
        startsAt: _at(d, h),
        venue: venue,
        perSide: n,
        mine: mine,
        reported: reported,
        gameId: game,
      );
    }
  }

  @override
  Future<RefereeStatus> refereeStatus() => _wait(() => _refStatus);

  @override
  Future<void> applyReferee({required String pitchId}) => _wait(() {
    if (_refStatus == RefereeStatus.none) _refStatus = RefereeStatus.pending;
    _changed();
  });

  @override
  Future<List<RefAvailability>> refereeAvailability() => _wait(
    () => _availability.values.toList()..sort((a, b) => a.weekday - b.weekday),
  );

  @override
  Future<void> setRefereeAvailability(RefAvailability a) => _wait(() {
    if (a.endHour <= a.startHour) throw ArgumentError('end before start');
    _availability[a.weekday] = a;
    _changed();
  });

  @override
  Future<void> clearRefereeAvailability(int weekday) => _wait(() {
    _availability.remove(weekday);
    _changed();
  });

  @override
  Future<List<RefJob>> refereeJobs() => _wait(() {
    if (_refStatus != RefereeStatus.approved) throw StateError('referees only');
    return _jobs.values.toList()
      ..sort((a, b) => a.startsAt.compareTo(b.startsAt));
  });

  @override
  Future<void> takeRefereeJob(String bookingId) => _wait(() {
    final j = _jobs[bookingId];
    if (j == null || j.mine) throw StateError('job not available');
    final clash = _jobs.values.any(
      (o) => o.mine && o.startsAt.difference(j.startsAt).inMinutes.abs() < 60,
    );
    if (clash) throw StateError('you already referee a game at that time');
    _jobs[bookingId] = j.copyWith(mine: true);
    _changed();
  });

  @override
  Future<void> submitMatchReport(String gameId, List<MatchEvent> events) =>
      _wait(() {
        final j = _jobs.values.firstWhere((x) => x.gameId == gameId && x.mine);
        if (j.reported) throw StateError('report already submitted');
        if (events.where((e) => e.type == MatchEventType.mvp).length > 1) {
          throw ArgumentError('only one MVP');
        }
        _jobs[j.bookingId] = j.copyWith(reported: true);
        _earn(RewardReason.referee, 40, 50, _clock());
        _me = _me.copyWith(xp: _me.xp + 40, coins: _me.coins + 50);
        _changed();
      });

  Player get _mePlayer => Player(
    handle: _me.handle,
    name: _me.name,
    wilayaId: _me.wilayaId,
    positions: _me.positions,
    xp: _me.xp,
    verified: _me.verified,
    played: _me.played,
  );

  void _seedTeams() {
    _teams['t1'] = Team(
      id: 't1',
      name: 'Harrach Lions',
      perSide: 7,
      captainHandle: _me.handle,
      iAmCaptain: true,
      members: [
        _mePlayer,
        for (final h in ['samy_lounis', 'adel_zitouni', 'nabil_ferhat'])
          _person(h),
      ],
      usualWeekday: DateTime.tuesday,
      usualHour: 21,
      usualPitchId: 'harrach',
      wins: 12,
      draws: 3,
      losses: 4,
    );
    _teams['t2'] = Team(
      id: 't2',
      name: 'Kouba Friday',
      perSide: 5,
      captainHandle: 'riad_mansouri',
      members: [_person('riad_mansouri'), _mePlayer, _person('mehdi_saadi')],
      wins: 5,
      losses: 6,
    );
  }

  Team _team(String id) => _teams[id] ?? (throw StateError('no team $id'));

  @override
  Future<List<Team>> myTeams() => _wait(() => _teams.values.toList());

  @override
  Future<Team> team(String id) => _wait(() => _team(id));

  @override
  Future<String> createTeam({required String name, required int perSide}) =>
      _wait(() {
        final id = 't${++_seq}';
        _teams[id] = Team(
          id: id,
          name: name.trim(),
          perSide: perSide,
          captainHandle: _me.handle,
          iAmCaptain: true,
          members: [_mePlayer],
        );
        _changed();
        return id;
      });

  @override
  Future<void> addTeamMember(String teamId, String handle) => _wait(() {
    final t = _team(teamId);
    if (!t.iAmCaptain) throw StateError('captain only');
    if (t.members.any((m) => m.handle == handle)) return;
    _teams[teamId] = t.copyWith(members: [...t.members, _person(handle)]);
    _changed();
  });

  @override
  Future<void> removeTeamMember(String teamId, String handle) => _wait(() {
    final t = _team(teamId);
    if (!t.iAmCaptain && handle != _me.handle) throw StateError('not allowed');
    if (handle == _me.handle) {
      _teams.remove(teamId);
    } else {
      _teams[teamId] = t.copyWith(
        members: t.members.where((m) => m.handle != handle).toList(),
      );
    }
    _changed();
  });

  @override
  Future<void> setUsualGame(
    String teamId, {
    required int weekday,
    required int hour,
    required String pitchId,
  }) => _wait(() {
    final t = _team(teamId);
    if (!t.iAmCaptain) throw StateError('captain only');
    _teams[teamId] = t.copyWith(
      usualWeekday: weekday,
      usualHour: hour,
      usualPitchId: pitchId,
    );
    _changed();
  });

  @override
  Future<void> reportPlayer(
    String handle, {
    String? gameId,
    required ReportReason reason,
    String note = '',
  }) => _wait(() {
    if (reason == ReportReason.noShow && gameId == null) {
      throw ArgumentError('a no-show report needs a game');
    }
    reports.add((handle, reason));
  });

  void _seedNotifications() {
    final n = _clock();
    _notifs.addAll([
      AppNotification(
        id: 1,
        kind: NotificationKind.stillComing,
        payload: {'game_id': 'g1', 'time': '21:00'},
        createdAt: n.subtract(const Duration(minutes: 20)),
      ),
      AppNotification(
        id: 2,
        kind: NotificationKind.friendRequest,
        payload: {'handle': 'farid_ouali', 'name': 'Farid Ouali'},
        createdAt: n.subtract(const Duration(hours: 2)),
      ),
      AppNotification(
        id: 3,
        kind: NotificationKind.spotOpen,
        payload: {'game_id': 'o1', 'pitch': 'Kouba Five', 'time': '22:00'},
        createdAt: n.subtract(const Duration(hours: 5)),
      ),
      AppNotification(
        id: 4,
        kind: NotificationKind.bookingConfirmed,
        payload: {'game_id': 'g1'},
        createdAt: n.subtract(const Duration(days: 1)),
        readAt: n.subtract(const Duration(hours: 20)),
      ),
      AppNotification(
        id: 5,
        kind: NotificationKind.rateGame,
        payload: {'game_id': 'p1'},
        createdAt: n.subtract(const Duration(days: 2)),
        readAt: n.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  @override
  Future<List<AppNotification>> notifications() =>
      _wait(() => List.of(_notifs));

  @override
  Future<void> markNotificationsRead() => _wait(() {
    if (!_notifs.any((x) => x.unread)) return;
    final now = _clock();
    for (var i = 0; i < _notifs.length; i++) {
      _notifs[i] = _notifs[i].copyWith(readAt: _notifs[i].readAt ?? now);
    }
    _changed();
  });

  @override
  Future<List<LedgerEntry>> walletHistory() =>
      _wait(() => _ledger.reversed.toList());

  void _earn(RewardReason r, int xp, int coins, DateTime at) => _ledger.add(
    LedgerEntry(reason: r, xpDelta: xp, coinsDelta: coins, createdAt: at),
  );

  @override
  Future<Set<String>> favoritePitchIds() => _wait(() => {..._favorites});

  @override
  Future<void> setFavorite(String pitchId, {required bool favorite}) =>
      _wait(() {
        favorite ? _favorites.add(pitchId) : _favorites.remove(pitchId);
        _changed();
      });

  @override
  Future<void> updateProfile({
    required String name,
    required String wilayaId,
    required List<Position> positions,
    required Level level,
    required String phone,
  }) => _wait(() {
    _me = _me.copyWith(
      name: name.trim(),
      wilayaId: wilayaId,
      positions: positions,
      level: level,
      phone: phone,
    );
    _changed();
  });

  @override
  Future<List<Pitch>> pitches({String query = ''}) => _wait(() {
    final q = query.trim().toLowerCase();
    return _pitches
        .where(
          (p) =>
              p.active &&
              (q.isEmpty ||
                  '${p.venue} ${p.venueAr} ${p.district}'
                      .toLowerCase()
                      .contains(q)),
        )
        .toList();
  });

  @override
  Future<Pitch> pitch(String id) =>
      _wait(() => _pitches.firstWhere((p) => p.id == id));

  @override
  Future<List<Slot>> slots(String pitchId, DateTime day) => _wait(() {
    final now = _clock();
    return [
      for (var h = 8; h <= 23; h++)
        () {
          final t = DateTime(day.year, day.month, day.day, h);
          final key = _slotKey(pitchId, t);
          // Deterministic sample availability, like the prototype.
          final x = (pitchId.length * 7 + day.day * 13 + h * 29) % 11;
          final blocked = _blocks.values.any(
            (b) => b.$1 == pitchId && b.$2.startsAt == t,
          );
          final state = _taken.contains(key) || blocked
              ? SlotState.booked
              : t.isBefore(now)
              ? SlotState.booked
              : x < 6
              ? SlotState.free
              : x < 9
              ? SlotState.booked
              : SlotState.pending;
          return Slot(t, state);
        }(),
    ];
  });

  @override
  Future<List<Game>> openGames() => _wait(
    () =>
        _games.values.where((g) => g.open && !g.full && g.me == null).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
  );

  @override
  Future<List<Game>> myUpcoming() => _wait(
    () =>
        _games.values
            .where(
              (g) =>
                  g.me != null &&
                  g.status != BookingStatus.cancelled &&
                  g.status != BookingStatus.completed,
            )
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
  );

  @override
  Future<List<Game>> myPast() => _wait(() => List.of(_past));

  @override
  Future<Game> game(String id) => _wait(() {
    final g = _games[id] ?? _past.where((p) => p.id == id).firstOrNull;
    if (g == null) throw StateError('unknown game $id');
    return g;
  });

  @override
  Future<int> liveSearching() => _wait(() => 47);

  @override
  Future<String> requestBooking({
    required String pitchId,
    required DateTime startsAt,
    required int perSide,
    bool withReferee = false,
  }) => _wait(() {
    if (!_me.verified) throw const NotVerifiedException();
    final p = _pitches.firstWhere((x) => x.id == pitchId);
    final id = 'b${_seq++}';
    _add(
      Game(
        id: id,
        pitch: p,
        startsAt: startsAt,
        perSide: perSide.clamp(3, p.maxPerSide),
        status: BookingStatus.requested,
        players: [
          GamePlayer(
            name: _me.name,
            handle: _me.handle,
            position: _me.positions.first,
            team: Side.a,
            reliability: _me.reliability,
            isMe: true,
            isBooker: true,
          ),
        ],
        code: 'MTK-${id.toUpperCase()}',
      ),
    );
    _changed();
    return id;
  });

  @override
  Future<void> joinGame(String gameId, Position position) => _wait(
    () => _update(gameId, (g) {
      if (g.full || g.me != null) return g;
      final a = g.players.where((p) => p.team == Side.a).length;
      final b = g.players.length - a;
      return g.copyWith(
        players: [
          ...g.players,
          GamePlayer(
            name: _me.name,
            handle: _me.handle,
            position: position,
            team: a <= b ? Side.a : Side.b,
            reliability: _me.reliability,
            isMe: true,
          ),
        ],
      );
    }),
  );

  @override
  Future<void> confirmComing(String gameId, {required bool coming}) => _wait(
    () => _update(
      gameId,
      (g) => coming
          ? g.copyWith(
              players: [
                for (final p in g.players)
                  p.isMe ? p.copyWith(confirmed: true) : p,
              ],
            )
          : g.copyWith(players: g.players.where((p) => !p.isMe).toList()),
    ),
  );

  @override
  Future<void> cancelBooking(String gameId) => _wait(() {
    _update(gameId, (g) => g.copyWith(status: BookingStatus.cancelled));
    // Server rule: a booker cancelling costs −20 XP / −10 coins.
    _earn(RewardReason.cancellation, -20, -10, _clock());
    _me = _me.copyWith(
      xp: (_me.xp - 20).clamp(0, 1 << 30),
      coins: (_me.coins - 10).clamp(0, 1 << 30),
    );
  });

  @override
  Future<void> setOpen(String gameId, {required bool open}) =>
      _wait(() => _update(gameId, (g) => g.copyWith(open: open)));

  @override
  Future<void> setPaid(String gameId, String handle, {required bool paid}) =>
      _wait(
        () => _update(
          gameId,
          (g) => g.copyWith(
            players: [
              for (final p in g.players)
                p.handle == handle ? p.copyWith(paid: paid) : p,
            ],
          ),
        ),
      );

  @override
  Future<void> setGameSize(String gameId, int perSide) => _wait(
    () => _update(gameId, (g) {
      final ok =
          perSide >= 3 &&
          perSide <= g.pitch.maxPerSide &&
          g.players.length <= perSide * 2;
      return ok ? g.copyWith(perSide: perSide) : g;
    }),
  );

  @override
  Future<Game?> findGame({required List<Position> positions}) => _wait(() {
    final open = _games.values.where((g) => g.open && !g.full && g.me == null);
    return open.isEmpty
        ? null
        : (open.toList()..sort((a, b) => a.startsAt.compareTo(b.startsAt)))
              .first;
  });

  // ── Manager ──────────────────────────────────────────────────────────

  @override
  Future<List<Game>> venueToday() => _wait(
    () =>
        _games.values
            .where((g) => g.id.startsWith('v') || g.id == 'g1' || g.id == 'o1')
            .where((g) => g.pitch.id == 'harrach')
            .toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt)),
  );

  @override
  Future<void> confirmBooking(String gameId) => _wait(
    () => _update(
      gameId,
      (g) => g.status.canMoveTo(BookingStatus.confirmed)
          ? g.copyWith(status: BookingStatus.confirmed)
          : g,
    ),
  );

  @override
  Future<Game> scanBooking(String code) => _wait(() {
    final g = _games.values.firstWhere(
      (g) => g.code == code && g.status.canMoveTo(BookingStatus.guaranteed),
      orElse: () => throw StateError('unknown ticket'),
    );
    _update(g.id, (x) => x.copyWith(status: BookingStatus.guaranteed));
    return _games[g.id]!;
  });

  @override
  Future<void> markNoShow(String gameId) => _wait(
    () => _update(
      gameId,
      (g) => g.status.canMoveTo(BookingStatus.noShow)
          ? g.copyWith(status: BookingStatus.noShow)
          : g,
    ),
  );

  void _seedReviews() {
    _refApps.add(RefApplication(id: 'ra1', player: _person('chouaib_benali')));
    _venueReports.add(
      VenueReport(
        id: 1,
        reporterName: 'Yacine Kaci',
        reported: _person('walid_djebbar'),
        reason: ReportReason.noShow,
        note: 'Said he was coming, never came.',
        gameStartsAt: _at(-2, 21),
      ),
    );
  }

  @override
  Future<List<RefApplication>> refereeApplications() =>
      _wait(() => List.of(_refApps));

  @override
  Future<void> decideRefereeApplication(String id, {required bool approve}) =>
      _wait(() {
        _refApps.removeWhere((a) => a.id == id);
        _changed();
      });

  @override
  Future<List<VenueReport>> venueReports() =>
      _wait(() => List.of(_venueReports));

  @override
  Future<void> reviewReport(int id, {required bool accept}) => _wait(() {
    _venueReports.removeWhere((r) => r.id == id);
    _changed();
  });

  @override
  Future<void> checkInPlayer(String gameId, String handle) => _wait(() {
    final g = _games[gameId];
    if (g == null || !g.players.any((p) => p.handle == handle)) {
      throw StateError('player not in this game');
    }
    _update(
      gameId,
      (g) => g.copyWith(
        players: [
          for (final p in g.players)
            p.handle == handle ? p.copyWith(attended: true) : p,
        ],
      ),
    );
  });

  @override
  Future<Venue> venue() => _wait(() => _venue);

  @override
  Future<List<Pitch>> venuePitches() => _wait(() => [_pitches[0]]);

  @override
  Future<void> setVenueHours({required int openHour, required int closeHour}) =>
      _wait(() {
        if (closeHour <= openHour) throw ArgumentError('close before open');
        _venue = _venue.copyWith(openHour: openHour, closeHour: closeHour);
        _changed();
      });

  @override
  Future<void> updatePitch(
    String pitchId, {
    required int priceDa,
    required int maxPerSide,
    required Set<Feature> features,
    required bool active,
  }) => _wait(() {
    if (priceDa <= 0 || maxPerSide < 3 || maxPerSide > 11) {
      throw ArgumentError('invalid pitch');
    }
    final i = _pitches.indexWhere((p) => p.id == pitchId);
    _pitches[i] = _pitches[i].copyWith(
      priceDa: priceDa,
      maxPerSide: maxPerSide,
      features: features,
      active: active,
    );
    _changed();
  });

  bool _slotTaken(String pitchId, DateTime t) =>
      _games.values.any(
        (g) =>
            g.pitch.id == pitchId &&
            g.startsAt == t &&
            g.status != BookingStatus.cancelled,
      ) ||
      _blocks.values.any((b) => b.$1 == pitchId && b.$2.startsAt == t);

  @override
  Future<List<CalendarEntry>> venueWeek(String pitchId, DateTime from) => _wait(
    () {
      final to = from.add(const Duration(days: 7));
      bool inWeek(DateTime t) => !t.isBefore(from) && t.isBefore(to);
      return [
        for (final g in _games.values)
          if (g.pitch.id == pitchId &&
              inWeek(g.startsAt) &&
              g.status != BookingStatus.cancelled)
            CalendarEntry(
              id: g.id,
              startsAt: g.startsAt,
              kind: CalendarKind.booking,
              label: g.players
                  .firstWhere((p) => p.isBooker, orElse: () => g.players.first)
                  .name,
              status: g.status,
              gameId: g.id,
            ),
        for (final b in _blocks.values)
          if (b.$1 == pitchId && inWeek(b.$2.startsAt)) b.$2,
      ]..sort((a, b) => a.startsAt.compareTo(b.startsAt));
    },
  );

  @override
  Future<void> blockSlot(
    String pitchId,
    DateTime startsAt, {
    String reason = '',
  }) => _wait(() {
    if (_slotTaken(pitchId, startsAt)) throw StateError('slot already booked');
    final id = 'b${++_seq}';
    _blocks[id] = (
      pitchId,
      CalendarEntry(
        id: id,
        startsAt: startsAt,
        kind: CalendarKind.blocked,
        label: reason.trim(),
      ),
    );
    _changed();
  });

  @override
  Future<void> addWalkIn(
    String pitchId,
    DateTime startsAt, {
    required String name,
    String? phone,
  }) => _wait(() {
    if (_slotTaken(pitchId, startsAt)) throw StateError('slot already booked');
    final id = 'w${++_seq}';
    _blocks[id] = (
      pitchId,
      CalendarEntry(
        id: id,
        startsAt: startsAt,
        kind: CalendarKind.walkIn,
        label: name.trim(),
        phone: phone,
      ),
    );
    _changed();
  });

  @override
  Future<void> removeBlock(String id) => _wait(() {
    _blocks.remove(id);
    _changed();
  });

  @override
  Future<List<Profile>> verificationQueue() => _wait(() => List.of(_queue));

  @override
  Future<void> verifyPlayer(String handle) => _wait(() {
    _queue.removeWhere((p) => p.handle == handle);
    _changed();
  });

  /// Demo only: lets testers see the unverified experience.
  void setVerified(bool v) {
    _me = _me.copyWith(verified: v);
    _changed();
  }
}
