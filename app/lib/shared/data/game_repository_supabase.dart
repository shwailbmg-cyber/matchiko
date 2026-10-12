import 'dart:async';

import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/calendar_entry.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/domain/ledger_entry.dart';
import 'package:matchiko/shared/domain/my_settings.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/referee.dart';
import 'package:matchiko/shared/domain/team.dart';
import 'package:matchiko/shared/domain/venue.dart';
import 'package:matchiko/shared/domain/venue_review.dart';
import 'package:matchiko/shared/domain/venue_stats.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

typedef _Json = Map<String, dynamic>;

/// The real backend: RLS-protected tables and the RPCs in
/// `supabase/migrations`. Every rule (prices, statuses, rewards, who may do
/// what) is checked by Postgres; this class only moves data.
class SupabaseGameRepository implements GameRepository {
  SupabaseGameRepository(this._db);

  final SupabaseClient _db;
  final _changes = StreamController<int>.broadcast();
  int _revision = 0;

  @override
  Stream<int> get changes => _changes.stream;

  /// After a write, screens refetch (Realtime can call this later too).
  void _changed() => _changes.add(++_revision);

  String get _me =>
      _db.auth.currentUser?.id ?? (throw StateError('signed out'));

  Future<dynamic> _rpc(String fn, [_Json? params]) =>
      _db.rpc(fn, params: params);

  Future<List<_Json>> _list(String fn, [_Json? params]) async =>
      ((await _rpc(fn, params) as List?) ?? const []).cast<_Json>();

  Future<T> _write<T>(Future<T> Function() f) async {
    final r = await f();
    _changed();
    return r;
  }

  Future<String> _userId(String handle) async =>
      await _rpc('user_id_of', {'p_handle': handle}) as String;

  Future<String> _bookingOf(String gameId) async =>
      (await _db
              .from('games')
              .select('booking_id')
              .eq('id', gameId)
              .single())['booking_id']
          as String;

  // ── Me ───────────────────────────────────────────────────────────────
  @override
  Future<Profile> me() async {
    final p = (await _list('get_my_profile')).single;
    final s = (await _list('my_stats')).single;
    return Profile(
      name: p['full_name'] as String? ?? '',
      handle: p['handle'] as String,
      xp: p['xp'] as int,
      coins: p['coins'] as int,
      verified: p['verified_at'] != null,
      positions: [
        for (final x in (p['positions'] as List?) ?? const [])
          Position.values.byName(x as String),
      ],
      reliability: s['reliability'] as int,
      played: s['played'] as int,
      wins: s['wins'] as int,
      goals: s['goals'] as int,
      isReferee: p['is_referee'] as bool? ?? false,
      wilayaId: p['city_id'] as String?,
      level: switch (p['level']) {
        final String l => Level.values.byName(l),
        _ => null,
      },
      phone: p['phone'] as String?,
    );
  }

  @override
  Future<void> updateProfile({
    required String name,
    required String wilayaId,
    required List<Position> positions,
    required Level level,
    required String phone,
  }) => _write(
    () => _db
        .from('profiles')
        .update({
          'full_name': name.trim(),
          'city_id': wilayaId,
          'positions': [for (final p in positions) p.name],
          'level': level.name,
          'phone': phone,
        })
        .eq('id', _me),
  );

  // ── Pitches ──────────────────────────────────────────────────────────
  @override
  Future<List<Pitch>> pitches({String query = ''}) async => [
    for (final j in await _list('list_pitches', {'p_query': query}))
      Pitch.fromJson(j),
  ];

  @override
  Future<Pitch> pitch(String id) async =>
      (await pitches()).firstWhere((p) => p.id == id);

  @override
  Future<List<Slot>> slots(String pitchId, DateTime day) async {
    final from = DateTime(day.year, day.month, day.day);
    final busy = await _list('pitch_busy', {
      'p_pitch': pitchId,
      'p_from': from.toUtc().toIso8601String(),
      'p_to': from.add(const Duration(days: 1)).toUtc().toIso8601String(),
    });
    final now = DateTime.now();
    return [
      for (var h = 8; h <= 23; h++)
        () {
          final t = DateTime(day.year, day.month, day.day, h);
          final hit = busy.where((b) {
            final s = DateTime.parse(b['starts_at'] as String).toLocal();
            final e = DateTime.parse(b['ends_at'] as String).toLocal();
            return s.isBefore(t.add(const Duration(hours: 1))) && e.isAfter(t);
          }).firstOrNull;
          final state = t.isBefore(now)
              ? SlotState.booked
              : hit == null
              ? SlotState.free
              : hit['pending'] == true
              ? SlotState.pending
              : SlotState.booked;
          return Slot(t, state);
        }(),
    ];
  }

  @override
  Future<Set<String>> favoritePitchIds() async => {
    for (final r in await _db.from('favorite_pitches').select('pitch_id'))
      r['pitch_id'] as String,
  };

  @override
  Future<void> setFavorite(String pitchId, {required bool favorite}) => _write(
    () => favorite
        ? _db.from('favorite_pitches').insert({'pitch_id': pitchId})
        : _db
              .from('favorite_pitches')
              .delete()
              .eq('pitch_id', pitchId)
              .eq('user_id', _me),
  );

  // ── Games ────────────────────────────────────────────────────────────
  @override
  Future<List<Game>> openGames() async => [
    for (final j in await _list('open_games')) Game.fromJson(j),
  ];

  @override
  Future<List<Game>> myUpcoming() async => [
    for (final j in await _list('my_games', {'p_past': false}))
      Game.fromJson(j),
  ];

  @override
  Future<List<Game>> myPast() async => [
    for (final j in await _list('my_games', {'p_past': true})) Game.fromJson(j),
  ];

  @override
  Future<Game> game(String id) async =>
      Game.fromJson(await _rpc('game_detail', {'p_game': id}) as _Json);

  @override
  Future<int> liveSearching() async => await _rpc('live_searching') as int;

  @override
  Future<String> requestBooking({
    required String pitchId,
    required DateTime startsAt,
    required int perSide,
    bool withReferee = false,
  }) => _write(() async {
    try {
      final booking = await _rpc('request_booking', {
        'p_pitch': pitchId,
        'p_starts_at': startsAt.toUtc().toIso8601String(),
        'p_with_referee': withReferee,
        'p_per_side': perSide,
      }) as String;
      return (await _db
              .from('games')
              .select('id')
              .eq('booking_id', booking)
              .single())['id']
          as String;
    } on PostgrestException catch (e) {
      if (e.message.contains('verification required')) {
        throw const NotVerifiedException();
      }
      rethrow;
    }
  });

  @override
  Future<void> joinGame(String gameId, Position position) => _write(
    () =>
        _rpc('join_open_game', {'p_game': gameId, 'p_position': position.name}),
  );

  @override
  Future<void> confirmComing(String gameId, {required bool coming}) => _write(
    () => _rpc('confirm_coming', {'p_game': gameId, 'p_coming': coming}),
  );

  @override
  Future<void> cancelBooking(String gameId) => _write(
    () async => _rpc('cancel_booking', {'p_booking': await _bookingOf(gameId)}),
  );

  @override
  Future<void> setOpen(String gameId, {required bool open}) =>
      _write(() => _rpc('set_game_open', {'p_game': gameId, 'p_open': open}));

  @override
  Future<void> setPaid(String gameId, String handle, {required bool paid}) =>
      _write(
        () => _rpc('set_player_paid', {
          'p_game': gameId,
          'p_handle': handle,
          'p_paid': paid,
        }),
      );

  @override
  Future<void> setGameSize(String gameId, int perSide) => _write(
    () => _rpc('set_game_size', {'p_game': gameId, 'p_per_side': perSide}),
  );

  /// Until server matchmaking (LOOP.md S21): the soonest open game.
  @override
  Future<Game?> findGame({required List<Position> positions}) async =>
      (await openGames()).firstOrNull;

  // ── Players and friends ──────────────────────────────────────────────
  @override
  Future<List<Player>> searchPlayers(String query) async => [
    for (final j in await _list('find_players', {'p_query': query}))
      Player.fromJson(j),
  ];

  @override
  Future<Player> player(String handle) async =>
      Player.fromJson(await _rpc('get_player', {'p_handle': handle}) as _Json);

  @override
  Future<List<Player>> friends() async => [
    for (final j in await _list('my_friends')) Player.fromJson(j),
  ];

  @override
  Future<void> addFriend(String handle) => _write(
    () async =>
        _db.from('friendships').insert({'addressee_id': await _userId(handle)}),
  );

  @override
  Future<void> acceptFriend(String handle) => _write(
    () async => _db
        .from('friendships')
        .update({'status': 'accepted'})
        .eq('requester_id', await _userId(handle))
        .eq('addressee_id', _me),
  );

  @override
  Future<void> removeFriend(String handle) => _write(() async {
    final other = await _userId(handle);
    await _db
        .from('friendships')
        .delete()
        .or(
          'and(requester_id.eq.$_me,addressee_id.eq.$other),'
          'and(requester_id.eq.$other,addressee_id.eq.$_me)',
        );
  });

  @override
  Future<void> reportPlayer(
    String handle, {
    String? gameId,
    required ReportReason reason,
    String note = '',
  }) => _write(
    () async => _db.from('player_reports').insert({
      'reported_id': await _userId(handle),
      'game_id': gameId,
      'reason': switch (reason) {
        ReportReason.noShow => 'no_show',
        _ => reason.name,
      },
      'note': note,
    }),
  );

  // ── Teams ────────────────────────────────────────────────────────────
  @override
  Future<List<Team>> myTeams() async => [
    for (final j in await _list('my_teams')) Team.fromJson(j),
  ];

  @override
  Future<Team> team(String id) async =>
      (await myTeams()).firstWhere((t) => t.id == id);

  @override
  Future<String> createTeam({required String name, required int perSide}) =>
      _write(() async {
        final id =
            (await _db
                    .from('teams')
                    .insert({
                      'name': name.trim(),
                      'captain_id': _me,
                      'per_side': perSide,
                    })
                    .select('id')
                    .single())['id']
                as String;
        await _db.from('team_members').insert({'team_id': id, 'user_id': _me});
        return id;
      });

  @override
  Future<void> addTeamMember(String teamId, String handle) => _write(
    () async => _db.from('team_members').insert({
      'team_id': teamId,
      'user_id': await _userId(handle),
    }),
  );

  @override
  Future<void> removeTeamMember(String teamId, String handle) => _write(
    () async => _db
        .from('team_members')
        .delete()
        .eq('team_id', teamId)
        .eq('user_id', await _userId(handle)),
  );

  @override
  Future<void> setUsualGame(
    String teamId, {
    required int weekday,
    required int hour,
    required String pitchId,
  }) => _write(
    () => _db
        .from('teams')
        .update({
          'usual_weekday': weekday,
          'usual_hour': hour,
          'usual_pitch_id': pitchId,
        })
        .eq('id', teamId),
  );

  // ── Settings and safety ──────────────────────────────────────────────
  @override
  Future<MySettings> mySettings() async {
    final s = (await _list('get_my_settings')).single;
    return MySettings(
      notifyNearby: s['notify_nearby'] as bool,
      notifyReminders: s['notify_reminders'] as bool,
      visibility: GamesVisibility.values.byName(
        s['games_visibility'] as String,
      ),
    );
  }

  @override
  Future<void> updateSettings(MySettings settings) => _write(
    () => _db
        .from('profiles')
        .update({
          'notify_nearby': settings.notifyNearby,
          'notify_reminders': settings.notifyReminders,
          'games_visibility': settings.visibility.name,
        })
        .eq('id', _me),
  );

  @override
  Future<List<Player>> blockedPlayers() async => [
    for (final j in await _list('my_blocked')) Player.fromJson(j),
  ];

  @override
  Future<void> block(String handle) => _write(
    () async =>
        _db.from('blocked_users').insert({'blocked_id': await _userId(handle)}),
  );

  @override
  Future<void> unblock(String handle) => _write(
    () async => _db
        .from('blocked_users')
        .delete()
        .eq('blocker_id', _me)
        .eq('blocked_id', await _userId(handle)),
  );

  @override
  Future<void> sendSupportMessage(String message) =>
      _db.from('support_messages').insert({'message': message.trim()});

  @override
  Future<void> deleteMyAccount() => _rpc('delete_my_account');

  // ── Notifications and wallet ─────────────────────────────────────────
  @override
  Future<List<AppNotification>> notifications() async => [
    for (final r
        in await _db
            .from('notifications')
            .select('id, kind, payload, read_at, created_at')
            .order('created_at', ascending: false)
            .limit(50))
      AppNotification.fromJson(r),
  ];

  @override
  Future<void> markNotificationsRead() => _write(
    () => _db
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .isFilter('read_at', null),
  );

  @override
  Future<List<LedgerEntry>> walletHistory() async => [
    for (final r
        in await _db
            .from('wallet_ledger')
            .select('reason, xp_delta, coins_delta, created_at')
            .order('created_at', ascending: false)
            .limit(50))
      LedgerEntry.fromJson(r),
  ];

  // ── Referee ──────────────────────────────────────────────────────────
  @override
  Future<RefereeStatus> refereeStatus() async {
    final p = (await _list('get_my_profile')).single;
    if (p['is_referee'] == true) return RefereeStatus.approved;
    final apps = await _db
        .from('referee_applications')
        .select('status')
        .eq('user_id', _me)
        .eq('status', 'pending');
    return apps.isEmpty ? RefereeStatus.none : RefereeStatus.pending;
  }

  @override
  Future<void> applyReferee({required String pitchId}) => _write(() async {
    final venue =
        (await _db
                .from('pitches')
                .select('venue_id')
                .eq('id', pitchId)
                .single())['venue_id']
            as String;
    await _db.from('referee_applications').insert({
      'venue_id': venue,
      'user_id': _me,
    });
  });

  @override
  Future<List<RefAvailability>> refereeAvailability() async => [
    for (final r
        in await _db
            .from('referee_availability')
            .select('weekday, start_hour, end_hour')
            .order('weekday'))
      RefAvailability(
        weekday: r['weekday'] as int,
        startHour: r['start_hour'] as int,
        endHour: r['end_hour'] as int,
      ),
  ];

  @override
  Future<void> setRefereeAvailability(RefAvailability a) => _write(
    () => _db.from('referee_availability').upsert({
      'user_id': _me,
      'weekday': a.weekday,
      'start_hour': a.startHour,
      'end_hour': a.endHour,
    }),
  );

  @override
  Future<void> clearRefereeAvailability(int weekday) => _write(
    () => _db
        .from('referee_availability')
        .delete()
        .eq('user_id', _me)
        .eq('weekday', weekday),
  );

  /// Open jobs from the board, then the games I referee.
  @override
  Future<List<RefJob>> refereeJobs() async {
    final open = await _list('open_referee_jobs');
    final mine = await _list('my_referee_jobs');
    DateTime at(_Json r) => DateTime.parse(r['starts_at'] as String).toLocal();
    return [
      for (final r in open)
        RefJob(
          bookingId: r['booking_id'] as String,
          startsAt: at(r),
          venue: r['venue_name'] as String,
          perSide: r['per_side'] as int? ?? 7,
        ),
      for (final r in mine)
        RefJob(
          bookingId: r['booking_id'] as String,
          startsAt: at(r),
          venue: r['venue_name'] as String,
          perSide: r['per_side'] as int? ?? 7,
          gameId: r['game_id'] as String?,
          mine: true,
          reported: r['reported'] as bool? ?? false,
        ),
    ];
  }

  @override
  Future<void> takeRefereeJob(String bookingId) =>
      _write(() => _rpc('take_referee_job', {'p_booking': bookingId}));

  /// The server takes player ids; the app knows handles.
  @override
  Future<void> submitMatchReport(String gameId, List<MatchEvent> events) =>
      _write(() async {
        final ids = <String, String>{};
        for (final e in events) {
          ids[e.handle] ??= await _userId(e.handle);
        }
        await _rpc('submit_match_report', {
          'p_game': gameId,
          'p_events': [
            for (final e in events)
              {
                'type': e.type.name,
                'team': e.side.name.toUpperCase(),
                'player_id': ids[e.handle],
              },
          ],
        });
      });

  // ── Manager ──────────────────────────────────────────────────────────
  Future<String> _myVenueId() async =>
      (await _db
              .from('venue_managers')
              .select('venue_id')
              .eq('user_id', _me)
              .limit(1)
              .single())['venue_id']
          as String;

  @override
  Future<void> confirmBooking(String gameId) => _write(
    () async =>
        _rpc('confirm_booking', {'p_booking': await _bookingOf(gameId)}),
  );

  @override
  Future<Game> bookingByQr(String token) async => Game.fromJson(
    await _rpc('booking_by_qr', {'p_token': token}) as Map<String, dynamic>,
  );

  @override
  Future<Game> scanBooking(String code) => _write(() async {
    final row = (await _list('scan_booking_qr', {'p_token': code})).single;
    final game = await _db
        .from('games')
        .select('id')
        .eq('booking_id', row['booking_id'] as String)
        .single();
    return this.game(game['id'] as String);
  });

  @override
  Future<void> markNoShow(String gameId) => _write(
    () async => _rpc('mark_no_show', {'p_booking': await _bookingOf(gameId)}),
  );

  @override
  Future<void> verifyPlayer(String handle) =>
      _write(() => _rpc('verify_player', {'p_handle': handle}));

  @override
  Future<void> decideRefereeApplication(String id, {required bool approve}) =>
      _write(
        () => _rpc(approve ? 'approve_referee' : 'reject_referee', {
          'p_application': id,
        }),
      );

  @override
  Future<void> reviewReport(int id, {required bool accept}) => _write(
    () => _rpc('review_player_report', {'p_report': id, 'p_accept': accept}),
  );

  @override
  Future<void> checkInPlayer(String gameId, String handle) => _write(
    () => _rpc('check_in_player', {'p_game': gameId, 'p_handle': handle}),
  );

  @override
  Future<VenueStats> venueStats(DateTime from, DateTime to) async =>
      VenueStats.fromJson(
        (await _list('venue_report', {
          'p_venue': await _myVenueId(),
          'p_from': from.toUtc().toIso8601String(),
          'p_to': to.toUtc().toIso8601String(),
        })).single,
      );

  @override
  Future<List<StaffMember>> venueStaff() async => [
    for (final r in await _list('venue_staff', {'p_venue': await _myVenueId()}))
      StaffMember(
        handle: r['handle'] as String,
        name: r['full_name'] as String,
        isMe: r['is_me'] as bool,
      ),
  ];

  @override
  Future<void> addStaff(String handle) => _write(
    () async => _rpc('add_venue_manager', {
      'p_venue': await _myVenueId(),
      'p_handle': handle.trim().replaceFirst('@', ''),
    }),
  );

  @override
  Future<void> removeStaff(String handle) => _write(
    () async => _rpc('remove_venue_manager', {
      'p_venue': await _myVenueId(),
      'p_handle': handle,
    }),
  );

  @override
  Future<Venue> venue() async {
    final v = await _db
        .from('venues')
        .select('id, name, open_hour, close_hour')
        .eq('id', await _myVenueId())
        .single();
    return Venue(
      id: v['id'] as String,
      name: v['name'] as String,
      openHour: v['open_hour'] as int,
      closeHour: v['close_hour'] as int,
    );
  }

  /// Includes hidden pitches (the player list shows active ones only).
  @override
  Future<List<Pitch>> venuePitches() async => [
    for (final r
        in await _db
            .from('pitches')
            .select(
              'id, name, max_per_side, price_da, features, active, '
              'venues(name, name_ar, district)',
            )
            .eq('venue_id', await _myVenueId())
            .order('name'))
      Pitch(
        id: r['id'] as String,
        venue: r['venues']['name'] as String,
        venueAr: (r['venues']['name_ar'] ?? r['venues']['name']) as String,
        district: r['venues']['district'] as String,
        km: 0,
        rating: 0,
        reviews: 0,
        maxPerSide: r['max_per_side'] as int,
        priceDa: r['price_da'] as int,
        features: {
          for (final f in (r['features'] as List?) ?? const [])
            Feature.values.byName(f as String),
        },
        active: r['active'] as bool,
      ),
  ];

  @override
  Future<void> setVenueHours({required int openHour, required int closeHour}) =>
      _write(
        () async => _db
            .from('venues')
            .update({'open_hour': openHour, 'close_hour': closeHour})
            .eq('id', await _myVenueId()),
      );

  @override
  Future<void> updatePitch(
    String pitchId, {
    required int priceDa,
    required int maxPerSide,
    required Set<Feature> features,
    required bool active,
  }) => _write(
    () => _db
        .from('pitches')
        .update({
          'price_da': priceDa,
          'max_per_side': maxPerSide,
          'features': [for (final f in features) f.name],
          'active': active,
        })
        .eq('id', pitchId),
  );

  @override
  Future<void> blockSlot(
    String pitchId,
    DateTime startsAt, {
    String reason = '',
  }) => _write(
    () => _db.from('pitch_blocks').insert({
      'pitch_id': pitchId,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': startsAt
          .add(const Duration(hours: 1))
          .toUtc()
          .toIso8601String(),
      'kind': 'blocked',
      'label': reason,
    }),
  );

  @override
  Future<void> addWalkIn(
    String pitchId,
    DateTime startsAt, {
    required String name,
    String? phone,
  }) => _write(
    () => _db.from('pitch_blocks').insert({
      'pitch_id': pitchId,
      'starts_at': startsAt.toUtc().toIso8601String(),
      'ends_at': startsAt
          .add(const Duration(hours: 1))
          .toUtc()
          .toIso8601String(),
      'kind': 'walk_in',
      'label': name,
      'phone': phone,
    }),
  );

  @override
  Future<void> removeBlock(String id) =>
      _write(() => _db.from('pitch_blocks').delete().eq('id', id));

  @override
  Future<List<Game>> venueToday() async => [
    for (final j in await _list('venue_today')) Game.fromJson(j),
  ];

  @override
  Future<List<CalendarEntry>> venueWeek(String pitchId, DateTime from) async =>
      [
        for (final r in await _list('venue_week', {
          'p_pitch': pitchId,
          'p_from': from.toUtc().toIso8601String(),
        }))
          CalendarEntry(
            id: r['id'] as String,
            startsAt: DateTime.parse(r['starts_at'] as String).toLocal(),
            kind: CalendarKind.values.byName(r['kind'] as String),
            label: r['label'] as String? ?? '',
            phone: r['phone'] as String?,
            status: switch (r['status']) {
              'no_show' => BookingStatus.noShow,
              final String st => BookingStatus.values.byName(st),
              _ => null,
            },
            gameId: r['game_id'] as String?,
          ),
      ];

  /// Players waiting for the in-person ID check (public fields only).
  @override
  Future<List<Profile>> verificationQueue() async => [
    for (final j in await _list('verification_queue'))
      () {
        final p = Player.fromJson(j);
        return Profile(
          name: p.name,
          handle: p.handle,
          xp: p.xp,
          coins: 0,
          verified: p.verified,
          positions: p.positions,
          reliability: 100,
          played: p.played,
          wins: 0,
          goals: 0,
        );
      }(),
  ];

  @override
  Future<List<RefApplication>> refereeApplications() async => [
    for (final r in await _list('venue_referee_applications'))
      RefApplication(
        id: r['id'] as String,
        player: Player.fromJson(r['player'] as _Json),
      ),
  ];

  @override
  Future<List<VenueReport>> venueReports() async => [
    for (final r in await _list('venue_open_reports'))
      VenueReport(
        id: r['id'] as int,
        reporterName: r['reporter_name'] as String,
        reported: Player.fromJson(r['reported'] as _Json),
        reason: switch (r['reason']) {
          'no_show' => ReportReason.noShow,
          final String x => ReportReason.values.byName(x),
          _ => ReportReason.other,
        },
        note: r['note'] as String? ?? '',
        gameStartsAt: DateTime.parse(r['game_starts_at'] as String).toLocal(),
      ),
  ];
}
