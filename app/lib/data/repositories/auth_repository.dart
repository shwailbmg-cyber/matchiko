import '../../domain/models/user_role.dart';

/// Signed-in user as the UI needs it.
class SessionUser {
  const SessionUser({required this.id, required this.role});

  final String id;
  final UserRole role;
}

/// Sign-in is free at launch: native Google, or a 6-digit code by email.
/// The phone number is a profile field the manager checks in person
/// (see docs/ARCHITECTURE.md § Sign-in).
abstract interface class AuthRepository {
  /// Current user, or null when signed out.
  SessionUser? get currentUser;

  /// Emits whenever the user signs in or out.
  Stream<SessionUser?> get changes;

  /// True in demo mode: the role is picked on the login screen.
  /// With Supabase the role always comes from the server.
  bool get isDemo;

  /// False when no Google client id was configured for this build.
  bool get supportsGoogle;

  Future<void> signInWithGoogle();

  Future<void> sendEmailCode(String email);

  Future<void> verifyEmailCode(String email, String code);

  /// Demo mode only.
  Future<void> demoSignIn(UserRole role);

  Future<void> signOut();
}
