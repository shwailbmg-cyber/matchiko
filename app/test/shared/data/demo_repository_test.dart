import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/data/game_repository_demo.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/position.dart';

void main() {
  final noon = DateTime(2026, 10, 10, 12);
  late DemoGameRepository repo;
  setUp(() => repo = DemoGameRepository(clock: () => noon));

  test('home data: open games exclude mine and full ones', () async {
    final open = await repo.openGames();
    expect(open, isNotEmpty);
    expect(open.every((g) => g.me == null && !g.full), isTrue);
    expect(open.first.startsAt.isBefore(open.last.startsAt), isTrue);
  });

  test('booking a free slot shows up as requested in my games', () async {
    final slots = await repo.slots('kouba', noon.add(const Duration(days: 1)));
    final free = slots.firstWhere((s) => s.state == SlotState.free);
    final id = await repo.requestBooking(
      pitchId: 'kouba',
      startsAt: free.startsAt,
      perSide: 9,
    );
    final g = await repo.game(id);
    expect(g.status, BookingStatus.requested);
    expect(g.perSide, 5, reason: 'clamped to the pitch maximum');
    expect(g.iAmBooker, isTrue);
    final again = await repo.slots('kouba', free.startsAt);
    expect(
      again.firstWhere((s) => s.startsAt == free.startsAt).state,
      SlotState.booked,
    );
  });

  test('unverified players cannot book', () async {
    repo.setVerified(false);
    expect(
      repo.requestBooking(pitchId: 'kouba', startsAt: noon, perSide: 5),
      throwsA(isA<NotVerifiedException>()),
    );
  });

  test('join, confirm, then leave a game', () async {
    final g = (await repo.openGames()).first;
    await repo.joinGame(g.id, Position.def);
    expect((await repo.game(g.id)).me?.position, Position.def);
    await repo.confirmComing(g.id, coming: false);
    expect((await repo.game(g.id)).me, isNull);
  });

  test(
    'manager confirms then scans: requested → confirmed → guaranteed',
    () async {
      final today = await repo.venueToday();
      final req = today.firstWhere((g) => g.status == BookingStatus.requested);
      await repo.confirmBooking(req.id);
      expect((await repo.game(req.id)).status, BookingStatus.confirmed);
      final scanned = await repo.scanBooking(req.code);
      expect(scanned.status, BookingStatus.guaranteed);
      expect(repo.scanBooking('MTK-NOPE'), throwsStateError);
    },
  );

  test('cancelling costs 20 XP and 10 coins', () async {
    final before = await repo.me();
    await repo.cancelBooking('g2');
    final after = await repo.me();
    expect(after.xp, before.xp - 20);
    expect(after.coins, before.coins - 10);
  });
}
