import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/app.dart';
import 'package:matchiko/data/repositories/auth_repository.dart';
import 'package:matchiko/data/repositories/game_repository.dart';
import 'package:matchiko/data/repositories/game_repository_demo.dart';
import 'package:matchiko/data/repositories/settings_repository.dart';
import 'package:matchiko/domain/models/user_role.dart';
import 'package:matchiko/ui/features/auth/view_models/session_view_model.dart';
import 'package:matchiko/ui/features/settings/view_models/settings_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

/// Server-backed auth stand-in: records calls, accepts code 123456.
class _FakeAuth implements AuthRepository {
  _FakeAuth({required this.supportsGoogle});

  @override
  final bool supportsGoogle;
  final _changes = StreamController<SessionUser?>.broadcast();
  final sentTo = <String>[];
  SessionUser? _user;

  @override
  SessionUser? get currentUser => _user;
  @override
  Stream<SessionUser?> get changes => _changes.stream;
  @override
  bool get isDemo => false;
  @override
  Future<void> signInWithGoogle() async {}
  @override
  Future<void> sendEmailCode(String email) async => sentTo.add(email);
  @override
  Future<void> verifyEmailCode(String email, String code) async {
    if (code != '123456') throw Exception('bad code');
    _user = const SessionUser(id: 'u1', role: UserRole.player);
    _changes.add(_user);
  }

  @override
  Future<void> demoSignIn(UserRole role) => throw UnsupportedError('');
  @override
  Future<void> signOut() async {}
}

Widget _app(AuthRepository auth) => MultiProvider(
  providers: [
    Provider<AuthRepository>.value(value: auth),
    ChangeNotifierProvider<GameRepository>(
      create: (_) => DemoGameRepository(latency: Duration.zero),
    ),
    ChangeNotifierProvider(create: (_) => SessionViewModel(auth)),
    ChangeNotifierProvider(
      create: (_) =>
          SettingsViewModel(SettingsRepository(SharedPreferencesAsync())),
    ),
  ],
  child: const MatchikoApp(),
);

void main() {
  setUp(() {
    SharedPreferencesAsyncPlatform.instance =
        InMemorySharedPreferencesAsync.empty();
  });

  testWidgets('email code sign-in', (tester) async {
    final auth = _FakeAuth(supportsGoogle: false);
    await tester.pumpWidget(_app(auth));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsNothing);

    await tester.enterText(find.byType(TextField), 'not-an-email');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(auth.sentTo, isEmpty);
    expect(find.text('Something went wrong. Try again.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), ' Amine@Gmail.com ');
    await tester.tap(find.text('Send code'));
    await tester.pumpAndSettle();
    expect(auth.sentTo, ['amine@gmail.com']);
    expect(find.textContaining('amine@gmail.com'), findsOneWidget);

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.text('Verify'));
    await tester.pumpAndSettle();
    expect(find.text('Ready to play tonight?'.toUpperCase()), findsOneWidget);
  });

  testWidgets('Google button shows when configured', (tester) async {
    await tester.pumpWidget(_app(_FakeAuth(supportsGoogle: true)));
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
  });
}
