import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matchiko/shared/domain/user_role.dart';
import 'package:matchiko/shared/providers.dart';

part 'login_controller.freezed.dart';

enum LoginStep { email, code }

@freezed
abstract class LoginState with _$LoginState {
  const factory LoginState({
    @Default(LoginStep.email) LoginStep step,
    @Default('') String email,
    @Default(false) bool busy,
    @Default(false) bool failed,
  }) = _LoginState;
}

/// Drives the login screen. Who is signed in lives in [sessionProvider].
class LoginController extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  static final _emailRe = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]{2,}$');
  static bool isEmail(String v) => _emailRe.hasMatch(v.trim());

  Future<void> signInWithGoogle() =>
      _run(() => ref.read(authRepositoryProvider).signInWithGoogle());

  Future<void> sendCode(String input) => _run(() async {
    final e = input.trim().toLowerCase();
    if (!isEmail(e)) throw const FormatException('email');
    await ref.read(authRepositoryProvider).sendEmailCode(e);
    state = state.copyWith(email: e, step: LoginStep.code);
  });

  Future<void> verifyCode(String code) => _run(
    () => ref
        .read(authRepositoryProvider)
        .verifyEmailCode(state.email, code.trim()),
  );

  /// Demo mode only: sign in straight away with the picked role.
  Future<void> demoSignIn(UserRole role) =>
      _run(() => ref.read(authRepositoryProvider).demoSignIn(role));

  void changeEmail() =>
      state = state.copyWith(step: LoginStep.email, failed: false);

  Future<void> _run(Future<void> Function() action) async {
    state = state.copyWith(busy: true, failed: false);
    try {
      await action();
    } catch (_) {
      if (ref.mounted) state = state.copyWith(failed: true);
    } finally {
      if (ref.mounted) state = state.copyWith(busy: false);
    }
  }
}

final loginControllerProvider =
    NotifierProvider.autoDispose<LoginController, LoginState>(
      LoginController.new,
    );
