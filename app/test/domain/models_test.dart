import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/domain/models/booking_status.dart';
import 'package:matchiko/domain/models/position.dart';
import 'package:matchiko/domain/models/rank.dart';
import 'package:matchiko/domain/models/phone_number.dart';
import 'package:matchiko/ui/features/auth/view_models/session_view_model.dart';

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

  test('formats have one line-up slot per player', () {
    for (final f in GameFormat.values) {
      expect(f.lineup.length, f.perTeam);
      expect(f.lineup.first, Position.gk);
    }
  });

  test('Algerian phone numbers normalise to E.164', () {
    expect(algerianMobileE164('0555 12 34 56'), '+213555123456');
    expect(algerianMobileE164('+213 661 00 00 00'), '+213661000000');
    expect(algerianMobileE164('770000000'), '+213770000000');
    expect(algerianMobileE164('021 00 00 00'), isNull, reason: 'landline');
    expect(algerianMobileE164('12'), isNull);
  });

  test('email check', () {
    expect(SessionViewModel.isEmail(' Amine@Gmail.com '), isTrue);
    expect(SessionViewModel.isEmail('amine@gmail'), isFalse);
    expect(SessionViewModel.isEmail('not an email'), isFalse);
  });
}
