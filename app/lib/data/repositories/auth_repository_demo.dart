import 'dart:async';

import '../../domain/models/user_role.dart';
import 'auth_repository.dart';

/// Offline stand-in used when no Supabase config is passed at build time.
/// The role is picked on the login screen, like the prototype.
class DemoAuthRepository implements AuthRepository {
  final _changes = StreamController<SessionUser?>.broadcast();
  SessionUser? _user;

  @override
  SessionUser? get currentUser => _user;

  @override
  Stream<SessionUser?> get changes => _changes.stream;

  @override
  bool get isDemo => true;

  @override
  bool get supportsGoogle => false;

  @override
  Future<void> signInWithGoogle() =>
      throw UnsupportedError('no Google sign-in in demo mode');

  @override
  Future<void> sendEmailCode(String email) async {}

  @override
  Future<void> verifyEmailCode(String email, String code) =>
      demoSignIn(UserRole.player);

  @override
  Future<void> demoSignIn(UserRole role) async {
    _user = SessionUser(id: 'demo', role: role);
    _changes.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }
}
