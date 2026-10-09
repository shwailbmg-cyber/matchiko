import 'dart:async';

import '../../domain/models/user_role.dart';
import 'auth_repository.dart';

/// Offline stand-in used when no Supabase config is passed at build time.
/// Accepts any code; the role is picked on the login screen, like the
/// prototype. Never shipped in release builds that have Supabase config.
class DemoAuthRepository implements AuthRepository {
  final _changes = StreamController<SessionUser?>.broadcast();
  SessionUser? _user;

  @override
  SessionUser? get currentUser => _user;

  @override
  Stream<SessionUser?> get changes => _changes.stream;

  @override
  bool get rolePickedOnClient => true;

  @override
  Future<void> sendCode(String phone) async {}

  @override
  Future<void> verifyCode(
    String phone,
    String code, {
    UserRole? demoRole,
  }) async {
    _user = SessionUser(id: 'demo', role: demoRole ?? UserRole.player);
    _changes.add(_user);
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _changes.add(null);
  }
}
