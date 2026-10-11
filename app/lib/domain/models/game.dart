import 'booking_status.dart';
import 'cost_share.dart';
import 'pitch.dart';
import 'position.dart';

enum Team { a, b }

class GamePlayer {
  const GamePlayer({
    required this.name,
    required this.handle,
    required this.position,
    required this.team,
    this.reliability = 100,
    this.paid = false,
    this.confirmed = true,
    this.guest = false,
    this.isMe = false,
    this.isBooker = false,
  });

  final String name;
  final String handle;
  final Position position;
  final Team team;
  final int reliability;
  final bool paid;
  final bool confirmed;

  /// Added by the booker, has no account.
  final bool guest;
  final bool isMe;
  final bool isBooker;

  String get initials => name
      .split(' ')
      .where((w) => w.isNotEmpty)
      .map((w) => w[0])
      .take(2)
      .join();

  GamePlayer copyWith({bool? paid, bool? confirmed}) => GamePlayer(
    name: name,
    handle: handle,
    position: position,
    team: team,
    reliability: reliability,
    paid: paid ?? this.paid,
    confirmed: confirmed ?? this.confirmed,
    guest: guest,
    isMe: isMe,
    isBooker: isBooker,
  );
}

/// A game = one booked hour on a pitch, with its players.
class Game {
  const Game({
    required this.id,
    required this.pitch,
    required this.startsAt,
    required this.perSide,
    required this.status,
    required this.players,
    this.open = false,
    this.waitlist = 0,
    this.competitive = false,
    this.code = '',
  });

  final String id;
  final Pitch pitch;
  final DateTime startsAt;
  final int perSide;
  final BookingStatus status;
  final List<GamePlayer> players;

  /// Free spots shown to other players.
  final bool open;
  final int waitlist;
  final bool competitive;

  /// Booking code shown under the QR.
  final String code;

  int get capacity => perSide * 2;
  int get spotsLeft => (capacity - players.length).clamp(0, capacity);
  bool get full => spotsLeft == 0;
  GamePlayer? get me => players.where((p) => p.isMe).firstOrNull;
  bool get iAmBooker => me?.isBooker ?? false;
  int get goalkeepers => players.where((p) => p.position == Position.gk).length;

  CostShare get share => CostShare.split(
    priceDa: pitch.priceDa,
    players: players.isEmpty ? capacity : players.length,
    goalkeepers: goalkeepers,
  );

  Game copyWith({
    BookingStatus? status,
    List<GamePlayer>? players,
    bool? open,
    int? perSide,
  }) => Game(
    id: id,
    pitch: pitch,
    startsAt: startsAt,
    perSide: perSide ?? this.perSide,
    status: status ?? this.status,
    players: players ?? this.players,
    open: open ?? this.open,
    waitlist: waitlist,
    competitive: competitive,
    code: code,
  );
}
