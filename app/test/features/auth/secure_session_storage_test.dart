import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/features/auth/data/secure_session_storage.dart';

void main() {
  setUp(() => FlutterSecureStorage.setMockInitialValues({}));

  test('persists, reads and removes the session', () async {
    const s = SecureSessionStorage();
    expect(await s.hasAccessToken(), isFalse);
    await s.persistSession('{"access_token":"x"}');
    expect(await s.hasAccessToken(), isTrue);
    expect(await s.accessToken(), '{"access_token":"x"}');
    await s.removePersistedSession();
    expect(await s.hasAccessToken(), isFalse);
  });
}
