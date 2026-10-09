import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/models/user_role.dart';
import 'auth_repository.dart';

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
  bool get rolePickedOnClient => false;

  @override
  Future<void> sendCode(String phone) =>
      _client.auth.signInWithOtp(phone: phone);

  @override
  Future<void> verifyCode(String phone, String code, {UserRole? demoRole}) =>
      _client.auth.verifyOTP(phone: phone, token: code, type: OtpType.sms);

  @override
  Future<void> signOut() => _client.auth.signOut();

  Future<void> dispose() async {
    await _sub.cancel();
    await _changes.close();
  }
}
