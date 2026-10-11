import 'dart:async';

import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/game_repository.dart';

/// In-memory sample data, same as the Claude Design prototype. Used when the
/// app is built without Supabase config (demo builds, tests).
class DemoGameRepository implements GameRepository {
  DemoGameRepository({DateTime Function()? clock, this.latency = Duration.zero})
    : _clock = clock ?? DateTime.now {
    _seed();
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
    Team team, {
    int rel = 95,
    bool paid = false,
    bool confirmed = true,
    bool guest = false,
  }) => GamePlayer(
    name: name,
    handle: name.toLowerCase().replaceAll(' ', '_'),
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
    team: Team.a,
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
    );
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
      _p('Yacine Kaci', Position.mid, Team.a, rel: 97, paid: true),
      _p('Hakim Mansouri', Position.def, Team.a, rel: 91, paid: true),
      _p('Bilal Tahar', Position.gk, Team.a, rel: 99),
      _p('Walid Djebbar', Position.def, Team.a, rel: 78, confirmed: false),
      _p('Karim', Position.fwd, Team.a, guest: true),
      _p('Redha Khelifi', Position.gk, Team.b, rel: 93, paid: true),
      _p('Karim Bouzid', Position.def, Team.b, rel: 88, paid: true),
      _p('Nassim Hadj', Position.def, Team.b, rel: 95),
      _p('Omar Saidi', Position.mid, Team.b, rel: 90, paid: true),
      _p('Raouf Ghali', Position.mid, Team.b, rel: 96, paid: true),
      _p('Ilyes Meziane', Position.fwd, Team.b, rel: 92),
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
            team: Team.a,
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

  List<GamePlayer> _filler(int n) => [
    for (var i = 0; i < n; i++)
      _p(
        _names[i % _names.length],
        Position.playable[(i ~/ 2) % 4],
        i.isEven ? Team.a : Team.b,
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
            team: Team.a,
            isBooker: true,
          ),
          ..._filler(9),
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

  @override
  Future<List<Pitch>> pitches({String query = ''}) => _wait(() {
    final q = query.trim().toLowerCase();
    return _pitches
        .where(
          (p) =>
              q.isEmpty ||
              '${p.venue} ${p.venueAr} ${p.district}'.toLowerCase().contains(q),
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
          final state = _taken.contains(key)
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
            team: Team.a,
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
      final a = g.players.where((p) => p.team == Team.a).length;
      final b = g.players.length - a;
      return g.copyWith(
        players: [
          ...g.players,
          GamePlayer(
            name: _me.name,
            handle: _me.handle,
            position: position,
            team: a <= b ? Team.a : Team.b,
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
