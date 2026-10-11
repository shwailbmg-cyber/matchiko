import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/models/user_role.dart';

enum LoginStep { email, code }

/// Holds who is signed in and drives the login screen. The router listens to
/// it to redirect between the login, player and manager areas.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this._auth) {
    _sub = _auth.changes.listen((_) => notifyListeners());
  }

  final AuthRepository _auth;
  late final StreamSubscription<SessionUser?> _sub;

  LoginStep step = LoginStep.email;
  String email = '';
  bool busy = false;
  bool failed = false;

  SessionUser? get user => _auth.currentUser;
  bool get signedIn => user != null;
  UserRole? get role => user?.role;
  bool get isDemo => _auth.isDemo;
  bool get canUseGoogle => _auth.supportsGoogle;

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static bool isEmail(String v) => _emailRe.hasMatch(v.trim());

  Future<void> signInWithGoogle() => _run(_auth.signInWithGoogle);

  Future<void> sendCode(String input) => _run(() async {
    final e = input.trim().toLowerCase();
    if (!isEmail(e)) throw const FormatException('email');
    await _auth.sendEmailCode(e);
    email = e;
    step = LoginStep.code;
  });

  Future<void> verifyCode(String code) =>
      _run(() => _auth.verifyEmailCode(email, code.trim()));

  /// Demo mode only: sign in straight away with the picked role.
  Future<void> demoSignIn(UserRole role) => _run(() => _auth.demoSignIn(role));

  void changeEmail() {
    step = LoginStep.email;
    failed = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    step = LoginStep.email;
    email = '';
  }

  Future<void> _run(Future<void> Function() action) async {
    busy = true;
    failed = false;
    notifyListeners();
    try {
      await action();
    } catch (_) {
      failed = true;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
