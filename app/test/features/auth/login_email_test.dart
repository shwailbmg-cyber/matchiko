import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';
import 'package:matchiko/shared/domain/user_role.dart';

import '../../helpers.dart';

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

Widget _app(AuthRepository auth) => testApp(auth: auth);

void main() {
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
