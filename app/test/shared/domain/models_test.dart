import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/rank.dart';
import 'package:matchiko/shared/domain/phone_number.dart';
import 'package:matchiko/features/auth/presentation/login_controller.dart';

void main() {
  group('Rank', () {
    test('tiers match the locked thresholds', () {
      expect(Rank.fromXp(0), Rank.bronze);
      expect(Rank.fromXp(499), Rank.bronze);
      expect(Rank.fromXp(500), Rank.silver);
      expect(Rank.fromXp(1240), Rank.gold);
      expect(Rank.fromXp(2000), Rank.elite);
      expect(Rank.fromXp(99999), Rank.legend);
      expect(Rank.fromXp(-50), Rank.bronze);
    });

    test('progress to next tier', () {
      expect(Rank.progress(1240), closeTo(.24, .001));
      expect(Rank.progress(3500), 1);
    });
  });

  group('BookingStatus', () {
    test('allowed transitions', () {
      expect(
        BookingStatus.requested.canMoveTo(BookingStatus.confirmed),
        isTrue,
      );
      expect(
        BookingStatus.requested.canMoveTo(BookingStatus.guaranteed),
        isTrue,
        reason: 'online SATIM payment skips the call',
      );
      expect(BookingStatus.confirmed.canMoveTo(BookingStatus.noShow), isTrue);
      expect(
        BookingStatus.guaranteed.canMoveTo(BookingStatus.requested),
        isFalse,
      );
      expect(BookingStatus.completed.isFinal, isTrue);
    });

    test('db values round-trip', () {
      for (final s in BookingStatus.values) {
        expect(BookingStatus.fromDb(s.dbValue), s);
      }
      expect(BookingStatus.noShow.dbValue, 'no_show');
    });
  });

  test('any size from 3 to 11 gets a sensible line-up', () {
    for (var n = GameFormat.min; n <= GameFormat.max; n++) {
      final f = GameFormat(n);
      expect(f.lineup.length, n);
      expect(f.lineup.first, Position.gk);
      expect(f.lineup.where((p) => p == Position.gk).length, 1);
      expect(f.lineup, contains(Position.fwd));
    }
    String shape(int n) {
      final l = GameFormat(n).lineup;
      int c(Position p) => l.where((x) => x == p).length;
      return '${c(Position.def)}-${c(Position.mid)}-${c(Position.fwd)}';
    }

    expect(shape(5), '2-1-1');
    expect(shape(7), '3-2-1');
    expect(shape(8), '3-3-1');
    expect(shape(11), '4-4-2');
    expect(const GameFormat(12).isValid, isFalse);
    expect(const GameFormat(7).label, '7v7');
  });

  test('Algerian phone numbers normalise to E.164', () {
    expect(algerianMobileE164('0555 12 34 56'), '+213555123456');
    expect(algerianMobileE164('+213 661 00 00 00'), '+213661000000');
    expect(algerianMobileE164('770000000'), '+213770000000');
    expect(algerianMobileE164('021 00 00 00'), isNull, reason: 'landline');
    expect(algerianMobileE164('12'), isNull);
  });

  test('email check', () {
    expect(LoginController.isEmail(' Amine@Gmail.com '), isTrue);
    expect(LoginController.isEmail('amine@gmail'), isFalse);
    expect(LoginController.isEmail('not an email'), isFalse);
  });
}
