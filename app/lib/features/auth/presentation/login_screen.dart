import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/shared/domain/user_role.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/logo_mark.dart';
import 'package:matchiko/core/widgets/zellij.dart';
import 'package:matchiko/core/settings/locale_controller.dart';
import 'package:matchiko/features/auth/presentation/login_controller.dart';
import 'package:matchiko/shared/providers.dart';

/// Login: Continue with Google, or a 6-digit code by email (both free). In
/// demo mode (no Supabase config) the prototype's "Continue as Player /
/// Stadium manager" cards sign in directly.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = ref.watch(loginControllerProvider);
    final isDemo = ref.watch(authRepositoryProvider).isDemo;
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            const _Hero(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  if (isDemo) ..._demo(context, l, vm) else ..._otp(l, vm),
                  if (vm.failed) ...[
                    const SizedBox(height: 12),
                    Text(
                      l.genericError,
                      style: const TextStyle(color: MkColors.red),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _otp(AppLocalizations l, LoginState vm) {
    final c = ref.read(loginControllerProvider.notifier);
    if (vm.step == LoginStep.email) {
      return [
        if (ref.read(authRepositoryProvider).supportsGoogle) ...[
          FilledButton.icon(
            onPressed: vm.busy ? null : c.signInWithGoogle,
            icon: const Text(
              'G',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            label: Text(l.continueWithGoogle),
          ),
          const SizedBox(height: 18),
          Text(
            l.orEmail,
            textAlign: TextAlign.center,
            style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
          ),
        ],
        _Label(l.emailLabel),
        TextField(
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          autofillHints: const [AutofillHints.email],
          decoration: const InputDecoration(hintText: 'nom@gmail.com'),
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: vm.busy ? null : () => c.sendCode(_email.text),
          child: Text(l.sendCode),
        ),
      ];
    }
    return [
      Text(l.codeSent(vm.email), style: const TextStyle(color: MkColors.sub)),
      const SizedBox(height: 12),
      _Label(l.codeLabel),
      TextField(
        controller: _code,
        keyboardType: TextInputType.number,
        textDirection: TextDirection.ltr,
        maxLength: 6,
        autofillHints: const [AutofillHints.oneTimeCode],
      ),
      FilledButton(
        onPressed: vm.busy ? null : () => c.verifyCode(_code.text),
        child: Text(l.verifyCode),
      ),
      TextButton(onPressed: c.changeEmail, child: Text(l.changeEmail)),
    ];
  }

  List<Widget> _demo(BuildContext context, AppLocalizations l, LoginState vm) {
    final c = ref.read(loginControllerProvider.notifier);
    return [
      Text(
        l.demoMode,
        style: const TextStyle(color: MkColors.sand, fontSize: 12.5),
      ),
      const SizedBox(height: 8),
      _Label(l.continueAs),
      for (final (role, emoji, title, sub) in [
        (UserRole.player, '⚽', l.rolePlayer, l.rolePlayerSub),
        (UserRole.manager, '🏟️', l.roleManager, l.roleManagerSub),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _RoleCard(
            emoji: emoji,
            title: title,
            subtitle: sub,
            onTap: vm.busy ? null : () => c.demoSignIn(role),
          ),
        ),
    ];
  }
}

class _Hero extends StatelessWidget {
  const _Hero();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: MkColors.primary.withValues(alpha: .28)),
        gradient: const LinearGradient(
          begin: Alignment(-.2, -1),
          end: Alignment(.2, 1),
          colors: [MkColors.heroViolet, MkColors.heroDeep],
        ),
      ),
      child: Zellij(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            children: [
              const Align(
                alignment: AlignmentDirectional.centerEnd,
                child: _LangPills(),
              ),
              const SizedBox(height: 14),
              DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: MkColors.primary.withValues(alpha: .45),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const LogoMark(size: 84),
              ),
              const SizedBox(height: 8),
              const MkLogo(markSize: 0, fontSize: 40),
              const SizedBox(height: 14),
              Text(
                l.loginTitle.toUpperCase(),
                textAlign: TextAlign.center,
                style: mkDisplay(context, size: 38),
              ),
              const SizedBox(height: 6),
              Text(
                l.loginSub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LangPills extends ConsumerWidget {
  const _LangPills();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (code, label) in [('en', 'EN'), ('fr', 'FR'), ('ar', 'ع')])
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: _Pill(
              label: label,
              on: locale.languageCode == code,
              onTap: () => ref.read(localeProvider.notifier).setLanguage(code),
            ),
          ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.on, required this.onTap});

  final String label;
  final bool on;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: on ? MkColors.text : MkColors.ink.withValues(alpha: .45),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          height: 30,
          constraints: const BoxConstraints(minWidth: 38),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: on ? MkColors.ink : MkColors.tint2,
            ),
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 8, bottom: 10),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: MkColors.sub,
        letterSpacing: .9,
      ),
    ),
  );
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MkColors.card2,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(emoji, style: const TextStyle(fontSize: 26)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: MkColors.sub,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.chevron_left
                    : Icons.chevron_right,
                color: MkColors.sub,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
