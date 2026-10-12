import 'dart:typed_data';

import 'package:matchiko/shared/domain/app_notification.dart';
import 'package:matchiko/shared/domain/calendar_entry.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/ledger_entry.dart';
import 'package:matchiko/shared/domain/my_settings.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/player.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/domain/referee.dart';
import 'package:matchiko/shared/domain/team.dart';
import 'package:matchiko/shared/domain/venue.dart';
import 'package:matchiko/shared/domain/venue_stats.dart';
import 'package:matchiko/shared/domain/venue_review.dart';

/// Everything the screens read and do about pitches, games and the signed-in
/// player. [changes] ticks when data changes (Realtime later), so the
/// providers that read it refetch.
///
/// Two implementations: [DemoGameRepository] (sample data, no server) and,
/// later, a Supabase one calling the RPCs in `supabase/migrations`. Rules
/// (prices, statuses, rewards) are enforced by the server, never here.
abstract interface class GameRepository {
  /// Emits a new number every time any data changes.
  Stream<int> get changes;

  Future<Profile> me();

  /// Onboarding and "Edit profile". The server checks every field again
  /// (handle, phone format, positions 1–4, level values).
  Future<void> updateProfile({
    required String name,
    required String wilayaId,
    required List<Position> positions,
    required Level level,
    required String phone,
  });
  Future<List<Pitch>> pitches({String query = ''});
  Future<Pitch> pitch(String id);
  Future<List<Slot>> slots(String pitchId, DateTime day);

  // ── Players and friends ──────────────────────────────────────────────
  /// Players by name or @handle (public profile columns only).
  Future<List<Player>> searchPlayers(String query);
  Future<Player> player(String handle);

  /// Friends, requests I received and requests I sent.
  Future<List<Player>> friends();
  Future<void> addFriend(String handle);
  Future<void> acceptFriend(String handle);

  /// Cancels a request, declines one, or removes a friend.
  Future<void> removeFriend(String handle);

  // ── Referee ──────────────────────────────────────────────────────────
  Future<RefereeStatus> refereeStatus();

  /// Applies at the venue of [pitchId]; its manager approves in person.
  Future<void> applyReferee({required String pitchId});
  Future<List<RefAvailability>> refereeAvailability();
  Future<void> setRefereeAvailability(RefAvailability a);
  Future<void> clearRefereeAvailability(int weekday);

  /// Open jobs first (job board), then my jobs.
  Future<List<RefJob>> refereeJobs();

  /// One referee per game, no overlaps (`take_referee_job`).
  Future<void> takeRefereeJob(String bookingId);
  Future<void> submitMatchReport(String gameId, List<MatchEvent> events);

  // ── Teams ────────────────────────────────────────────────────────────
  Future<List<Team>> myTeams();
  Future<Team> team(String id);

  /// Returns the new team's id. I am its captain.
  Future<String> createTeam({required String name, required int perSide});

  /// Captain only (RLS).
  Future<void> addTeamMember(String teamId, String handle);

  /// Captain removes anyone; a member removes themselves (leave).
  Future<void> removeTeamMember(String teamId, String handle);

  /// Captain only.
  Future<void> setUsualGame(
    String teamId, {
    required int weekday,
    required int hour,
    required String pitchId,
  });

  // ── Settings and safety ──────────────────────────────────────────────
  Future<MySettings> mySettings();
  Future<void> updateSettings(MySettings settings);
  Future<List<Player>> blockedPlayers();

  /// Blocking also ends a friendship and stops friend requests.
  Future<void> block(String handle);
  Future<void> unblock(String handle);
  Future<void> sendSupportMessage(String message);

  /// Refused while I have upcoming confirmed bookings or am the only
  /// manager of a venue. Sign out afterwards.
  Future<void> deleteMyAccount();

  /// About a game both of us played, or about behaviour in general.
  /// A no-show report needs [gameId]. Checked by RLS on `player_reports`.
  Future<void> reportPlayer(
    String handle, {
    String? gameId,
    required ReportReason reason,
    String note = '',
  });

  // ── Notifications ────────────────────────────────────────────────────
  /// Newest first.
  Future<List<AppNotification>> notifications();
  Future<void> markNotificationsRead();

  /// My XP and coin changes, newest first.
  Future<List<LedgerEntry>> walletHistory();

  /// Ids of the pitches I marked with a heart (`favorite_pitches`).
  Future<Set<String>> favoritePitchIds();
  Future<void> setFavorite(String pitchId, {required bool favorite});

  /// Open games near me that still need players.
  Future<List<Game>> openGames();
  Future<List<Game>> myUpcoming();
  Future<List<Game>> myPast();
  Future<Game> game(String id);

  /// Players searching near me right now (home counter).
  Future<int> liveSearching();

  /// Returns the new game's id. Throws [NotVerifiedException] when the
  /// player isn't verified yet.
  Future<String> requestBooking({
    required String pitchId,
    required DateTime startsAt,
    required int perSide,
    bool withReferee = false,
  });
  Future<void> joinGame(String gameId, Position position);
  Future<void> confirmComing(String gameId, {required bool coming});
  Future<void> cancelBooking(String gameId);
  Future<void> setOpen(String gameId, {required bool open});
  Future<void> setPaid(String gameId, String handle, {required bool paid});
  Future<void> setGameSize(String gameId, int perSide);

  /// Simple matchmaking: best open game for these positions, or null.
  Future<Game?> findGame({required List<Position> positions});

  // ── Manager ──────────────────────────────────────────────────────────
  Future<List<Game>> venueToday();
  Future<void> confirmBooking(String gameId);

  /// Replaces my profile photo (a small JPEG), or removes it when null.
  Future<void> setAvatar(Uint8List? jpeg);

  /// This device's push token (FCM), kept while the user is signed in.
  Future<void> registerPushToken(String token, String platform);
  Future<void> unregisterPushToken(String token);

  /// The booking a ticket QR token belongs to (manager's venue only).
  Future<Game> bookingByQr(String token);

  /// Returns the booking the QR code belongs to, now Guaranteed.
  Future<Game> scanBooking(String code);
  Future<void> markNoShow(String gameId);
  Future<List<Profile>> verificationQueue();

  /// Pending referee requests at my venue (approve after checking ID).
  Future<List<RefApplication>> refereeApplications();
  Future<void> decideRefereeApplication(String id, {required bool approve});

  /// Open reports about games at my venue.
  Future<List<VenueReport>> venueReports();

  /// Accepting a no-show applies the penalty (`review_player_report`).
  Future<void> reviewReport(int id, {required bool accept});

  /// Marks a player as arrived (their QR shows the @handle).
  Future<void> checkInPlayer(String gameId, String handle);

  /// Bookings, cash and occupancy at my venue for [from]..[to].
  Future<VenueStats> venueStats(DateTime from, DateTime to);
  Future<List<StaffMember>> venueStaff();

  /// Adds a verified player as manager of my venue.
  Future<void> addStaff(String handle);

  /// A venue always keeps at least one manager.
  Future<void> removeStaff(String handle);

  /// My venue and its pitches.
  Future<Venue> venue();
  Future<List<Pitch>> venuePitches();
  Future<void> setVenueHours({required int openHour, required int closeHour});

  /// Manager only (RLS); the server checks price > 0 and size 3–11.
  Future<void> updatePitch(
    String pitchId, {
    required int priceDa,
    required int maxPerSide,
    required Set<Feature> features,
    required bool active,
  });

  /// Everything on [pitchId] for the 7 days from [from] (midnight).
  Future<List<CalendarEntry>> venueWeek(String pitchId, DateTime from);

  /// Manager only; fails when the hour is taken.
  Future<void> blockSlot(
    String pitchId,
    DateTime startsAt, {
    String reason = '',
  });
  Future<void> addWalkIn(
    String pitchId,
    DateTime startsAt, {
    required String name,
    String? phone,
  });

  /// Removes a block or a walk-in.
  Future<void> removeBlock(String id);
  Future<void> verifyPlayer(String handle);
}

class NotVerifiedException implements Exception {
  const NotVerifiedException();
}
