import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/qr_payload.dart';

void main() {
  test('round trip', () {
    expect(
      (QrPayload.parse('${const BookingQr('ab12')}') as BookingQr).token,
      'ab12',
    );
    expect(
      (QrPayload.parse(' matchiko:player:yacine ') as PlayerQr).handle,
      'yacine',
    );
  });

  test('rejects anything else', () {
    for (final s in [
      '',
      'hello',
      'matchiko:booking:',
      'matchiko:admin:x',
      'other:player:x',
      'matchiko:player:a:b',
      'https://evil.example/matchiko:player:x',
    ]) {
      expect(QrPayload.parse(s), isNull, reason: s);
    }
  });
}
