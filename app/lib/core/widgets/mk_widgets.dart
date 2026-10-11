import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';

/// Small shared pieces from the prototype's CSS (`.av`, `.tag`, `.pb`, `.rb`…).

const _avatarColors = [
  MkColors.primary,
  MkColors.sand,
  Color(0xFF6CB4EE),
  MkColors.terra,
  Color(0xFFB39DDB),
  Color(0xFF4DD0C8),
];

class MkAvatar extends StatelessWidget {
  const MkAvatar(this.initials, {super.key, this.size = 36, this.seed = 0});

  final String initials;
  final double size;
  final int seed;

  @override
  Widget build(BuildContext context) {
    final c = _avatarColors[seed.abs() % _avatarColors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: c.withValues(alpha: .15),
      ),
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: c,
          fontWeight: FontWeight.w800,
          fontSize: size * .36,
        ),
      ),
    );
  }
}

/// Rounded dark card with the thin line border.
class MkCard extends StatelessWidget {
  const MkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(MkRadius.card),
      side: BorderSide(color: borderColor ?? MkColors.line),
    );
    return Material(
      color: MkColors.card,
      shape: shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}

class MkTag extends StatelessWidget {
  const MkTag(this.text, {super.key, this.color = MkColors.primary});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .13),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text,
      style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w800),
    ),
  );
}

/// Section title row: "Games missing players ........ See all".
class MkSection extends StatelessWidget {
  const MkSection(this.title, {super.key, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.fromSTEB(20, 26, 20, 12),
    child: Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

/// Uppercase small label above a form field.
class MkLabel extends StatelessWidget {
  const MkLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(top: 20, bottom: 10),
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

/// Big condensed uppercase page title.
class MkTitle extends StatelessWidget {
  const MkTitle(this.text, {super.key, this.size = 38});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) =>
      Text(text.toUpperCase(), style: mkDisplay(context, size: size));
}

/// Loading / error / data for an [AsyncValue], used by every screen.
/// Keeps showing the previous data while a refresh runs.
class AsyncView<T> extends StatelessWidget {
  const AsyncView(
    this.value, {
    super.key,
    required this.onRetry,
    required this.data,
  });

  final AsyncValue<T> value;
  final VoidCallback onRetry;
  final Widget Function(T data) data;

  @override
  Widget build(BuildContext context) => value.when(
    data: data,
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (_, _) => Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context).genericError,
            style: const TextStyle(color: MkColors.sub),
          ),
          TextButton(
            onPressed: onRetry,
            child: Text(AppLocalizations.of(context).retry),
          ),
        ],
      ),
    ),
  );
}
