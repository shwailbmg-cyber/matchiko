import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../domain/models/user_role.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../core/theme/mk_colors.dart';
import '../../../core/theme/mk_theme.dart';
import '../../../core/widgets/logo_mark.dart';
import '../../../core/widgets/zellij.dart';
import '../../settings/view_models/settings_view_model.dart';
import '../view_models/session_view_model.dart';

/// Login: phone number → SMS code. In demo mode (no Supabase config) the
/// prototype's "Continue as Player / Stadium manager" cards sign in directly.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _code = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final vm = context.watch<SessionViewModel>();
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
                  if (vm.isDemo) ..._demo(context, l, vm) else ..._otp(l, vm),
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

  List<Widget> _otp(AppLocalizations l, SessionViewModel vm) {
    if (vm.step == LoginStep.phone) {
      return [
        _Label(l.phone),
        TextField(
          controller: _phone,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          autofillHints: const [AutofillHints.telephoneNumber],
          decoration: const InputDecoration(
            prefixText: '🇩🇿 +213  ',
            hintText: '555 12 34 56',
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: vm.busy ? null : () => vm.sendCode(_phone.text),
          child: Text(l.sendCode),
        ),
      ];
    }
    return [
      Text(l.codeSent(vm.phone), style: const TextStyle(color: MkColors.sub)),
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
        onPressed: vm.busy ? null : () => vm.verifyCode(_code.text),
        child: Text(l.verifyCode),
      ),
      TextButton(onPressed: vm.changeNumber, child: Text(l.changeNumber)),
    ];
  }

  List<Widget> _demo(
    BuildContext context,
    AppLocalizations l,
    SessionViewModel vm,
  ) {
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
            onTap: vm.busy ? null : () => vm.demoSignIn(role),
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
        border: Border.all(color: MkColors.lime.withValues(alpha: .28)),
        gradient: const LinearGradient(
          begin: Alignment(-.2, -1),
          end: Alignment(.2, 1),
          colors: [Color(0xFF1F7C47), Color(0xFF0D2E1B)],
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
                      color: MkColors.lime.withValues(alpha: .45),
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

class _LangPills extends StatelessWidget {
  const _LangPills();

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (code, label) in [('en', 'EN'), ('fr', 'FR'), ('ar', 'ع')])
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 4),
            child: _Pill(
              label: label,
              on: settings.locale.languageCode == code,
              onTap: () => settings.setLanguage(code),
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
              color: on ? MkColors.ink : const Color(0xFFB5D6C1),
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
