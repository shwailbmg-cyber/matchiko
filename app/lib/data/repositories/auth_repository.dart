import '../../domain/models/user_role.dart';

/// Signed-in user as the UI needs it.
class SessionUser {
  const SessionUser({required this.id, required this.role});

  final String id;
  final UserRole role;
}

/// Phone OTP sign-in. Algerian numbers only for now (+213).
abstract interface class AuthRepository {
  /// Current user, or null when signed out.
  SessionUser? get currentUser;

  /// Emits whenever the user signs in or out.
  Stream<SessionUser?> get changes;

  /// True when the role is picked on the login screen (demo mode only).
  /// With Supabase the role always comes from the server.
  bool get rolePickedOnClient;

  Future<void> sendCode(String phone);

  /// [demoRole] is only used when [rolePickedOnClient] is true.
  Future<void> verifyCode(String phone, String code, {UserRole? demoRole});

  Future<void> signOut();
}
