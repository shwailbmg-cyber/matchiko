import 'package:flutter/material.dart';

import '../../../l10n/gen/app_localizations.dart';
import '../theme/mk_colors.dart';
import '../theme/mk_theme.dart';
import 'logo_mark.dart';

/// Placeholder for screens not built yet. Each one names the prototype
/// screen it will implement (see `docs/ROADMAP.md`).
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({
    super.key,
    required this.title,
    required this.prototypeScreen,
    this.actions = const [],
  });

  final String title;

  /// `SC.<name>` in `design/prototype/*.js`.
  final String prototypeScreen;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MkColors.bg,
        title: Text(title.toUpperCase(), style: mkDisplay(context, size: 32)),
        actions: actions,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const LogoMark(size: 64),
            const SizedBox(height: 16),
            Text(
              l.comingSoon,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
            ),
            const SizedBox(height: 4),
            Text(
              'SC.$prototypeScreen',
              style: const TextStyle(color: MkColors.faint, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
