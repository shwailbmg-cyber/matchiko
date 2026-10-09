import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../data/repositories/auth_repository.dart';
import '../../../../domain/models/user_role.dart';

enum LoginStep { phone, code }

/// Holds who is signed in and drives the login screen. The router listens to
/// it to redirect between the login, player and manager areas.
class SessionViewModel extends ChangeNotifier {
  SessionViewModel(this._auth) {
    _sub = _auth.changes.listen((_) => notifyListeners());
  }

  final AuthRepository _auth;
  late final StreamSubscription<SessionUser?> _sub;

  LoginStep step = LoginStep.phone;
  String phone = '';
  bool busy = false;
  bool failed = false;

  SessionUser? get user => _auth.currentUser;
  bool get signedIn => user != null;
  UserRole? get role => user?.role;
  bool get isDemo => _auth.rolePickedOnClient;

  /// Normalises a local Algerian number ("0555 12 34 56" or "555123456")
  /// to E.164 (+213555123456). Returns null when it isn't a mobile number.
  static String? toE164(String input) {
    var d = input.replaceAll(RegExp(r'\D'), '');
    if (d.startsWith('213')) d = d.substring(3);
    if (d.startsWith('0')) d = d.substring(1);
    return RegExp(r'^[567]\d{8}$').hasMatch(d) ? '+213$d' : null;
  }

  Future<void> sendCode(String input) => _run(() async {
    final e164 = toE164(input);
    if (e164 == null) throw const FormatException('phone');
    await _auth.sendCode(e164);
    phone = e164;
    step = LoginStep.code;
  });

  Future<void> verifyCode(String code) =>
      _run(() => _auth.verifyCode(phone, code.trim()));

  /// Demo mode only: sign in straight away with the picked role.
  Future<void> demoSignIn(UserRole role) =>
      _run(() => _auth.verifyCode('+213000000000', '000000', demoRole: role));

  void changeNumber() {
    step = LoginStep.phone;
    failed = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    step = LoginStep.phone;
    phone = '';
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
