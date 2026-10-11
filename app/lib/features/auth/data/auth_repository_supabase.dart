import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:matchiko/core/env.dart';
import 'package:matchiko/shared/domain/user_role.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client) {
    _sub = _client.auth.onAuthStateChange.listen((state) async {
      final session = state.session;
      _user = session == null ? null : await _loadUser(session.user.id);
      _changes.add(_user);
    });
  }

  final SupabaseClient _client;
  final _changes = StreamController<SessionUser?>.broadcast();
  late final StreamSubscription<AuthState> _sub;
  SessionUser? _user;
  bool _googleReady = false;

  /// The role is decided by the database (`venue_managers` table), not by
  /// anything the client sends.
  Future<SessionUser> _loadUser(String id) async {
    final role = await _client.rpc<String>('my_role');
    return SessionUser(id: id, role: UserRole.fromDb(role));
  }

  @override
  SessionUser? get currentUser => _user;

  @override
  Stream<SessionUser?> get changes => _changes.stream;

  @override
  bool get isDemo => false;

  @override
  bool get supportsGoogle => Env.googleWebClientId.isNotEmpty;

  /// Native Google sign-in, then hand the ID token to Supabase.
  @override
  Future<void> signInWithGoogle() async {
    final google = GoogleSignIn.instance;
    if (!_googleReady) {
      await google.initialize(serverClientId: Env.googleWebClientId);
      _googleReady = true;
    }
    final account = await google.authenticate();
    final idToken = account.authentication.idToken;
    if (idToken == null) throw const AuthException('No Google ID token');
    await _client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
  }

  @override
  Future<void> sendEmailCode(String email) =>
      _client.auth.signInWithOtp(email: email);

  @override
  Future<void> verifyEmailCode(String email, String code) =>
      _client.auth.verifyOTP(email: email, token: code, type: OtpType.email);

  @override
  Future<void> demoSignIn(UserRole role) =>
      throw UnsupportedError('demo sign-in is only available without Supabase');

  @override
  Future<void> signOut() async {
    if (_googleReady) await GoogleSignIn.instance.signOut();
    await _client.auth.signOut();
  }

  Future<void> dispose() async {
    await _sub.cancel();
    await _changes.close();
  }
}
