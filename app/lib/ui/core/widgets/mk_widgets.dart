import 'package:flutter/material.dart';

import '../../../domain/models/booking_status.dart';
import '../../../domain/models/position.dart';
import '../../../domain/models/rank.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../theme/mk_colors.dart';
import '../theme/mk_theme.dart';

/// Small shared pieces from the prototype's CSS (`.av`, `.tag`, `.pb`, `.rb`…).

const _avatarColors = [
  MkColors.lime,
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
  const MkTag(this.text, {super.key, this.color = MkColors.lime});

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

class PositionBadge extends StatelessWidget {
  const PositionBadge(this.position, {super.key});

  final Position position;

  static const colors = {
    Position.gk: MkColors.sand,
    Position.def: Color(0xFF6CB4EE),
    Position.mid: MkColors.lime,
    Position.fwd: MkColors.terra,
    Position.ref: Color(0xFFF4D35E),
  };

  @override
  Widget build(BuildContext context) {
    final c = colors[position]!;
    return Container(
      height: 27,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: c.withValues(alpha: .12),
        border: Border.all(color: c.withValues(alpha: .32)),
        borderRadius: BorderRadius.circular(99),
      ),
      alignment: Alignment.center,
      child: Text(
        '${position.emoji} ${positionName(AppLocalizations.of(context), position)}',
        style: TextStyle(color: c, fontSize: 12, fontWeight: FontWeight.w800),
      ),
    );
  }
}

String positionName(AppLocalizations l, Position p) => switch (p) {
  Position.gk => l.posfGK,
  Position.def => l.posfDEF,
  Position.mid => l.posfMID,
  Position.fwd => l.posfFWD,
  Position.ref => l.posfREF,
};

String positionShort(AppLocalizations l, Position p) => switch (p) {
  Position.gk => l.posGK,
  Position.def => l.posDEF,
  Position.mid => l.posMID,
  Position.fwd => l.posFWD,
  Position.ref => 'REF',
};

String rankName(AppLocalizations l, Rank r) => switch (r) {
  Rank.bronze => l.rankBronze,
  Rank.silver => l.rankSilver,
  Rank.gold => l.rankGold,
  Rank.elite => l.rankElite,
  Rank.legend => l.rankLegend,
};

class RankBadge extends StatelessWidget {
  const RankBadge(this.rank, {super.key});

  final Rank rank;

  static const _grad = {
    Rank.bronze: [Color(0xFFE2A06F), Color(0xFFA8653B), Color(0xFF2A1406)],
    Rank.silver: [Color(0xFFEEF2F5), Color(0xFF9AA6B0), Color(0xFF1C2227)],
    Rank.gold: [Color(0xFFF8DC85), Color(0xFFD49E2A), Color(0xFF3A2702)],
    Rank.elite: [Color(0xFFA8ECFF), Color(0xFF4F9BE3), Color(0xFF06243A)],
    Rank.legend: [Color(0xFFF7B2FF), Color(0xFF8F63F5), Color(0xFF1E0633)],
  };

  @override
  Widget build(BuildContext context) {
    final g = _grad[rank]!;
    return Container(
      height: 24,
      padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 10, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [g[0], g[1]]),
        borderRadius: BorderRadius.circular(99),
      ),
      alignment: Alignment.center,
      child: Text(
        '${rank.emoji} ${rankName(AppLocalizations.of(context), rank)}',
        style: TextStyle(
          color: g[2],
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) =>
      MkTag('✔ ${AppLocalizations.of(context).verified}', color: MkColors.blue);
}

(String, Color) statusLabel(AppLocalizations l, BookingStatus s) => switch (s) {
  BookingStatus.requested => (l.stRequested, MkColors.sand),
  BookingStatus.confirmed => (l.stConfirmed, MkColors.blue),
  BookingStatus.guaranteed => (l.stGuaranteed, MkColors.lime),
  BookingStatus.completed => (l.played, MkColors.sub),
  BookingStatus.cancelled => (l.cancelled, MkColors.red),
  BookingStatus.noShow => (l.noshow, MkColors.red),
};

class StatusTag extends StatelessWidget {
  const StatusTag(this.status, {super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final (t, c) = statusLabel(AppLocalizations.of(context), status);
    return MkTag(t, color: c);
  }
}

/// Requested → Confirmed → Guaranteed, with a one-line explanation.
class StatusLadder extends StatelessWidget {
  const StatusLadder(this.status, {super.key});

  final BookingStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final step = status.ladderStep;
    final labels = [l.stRequested, l.stConfirmed, l.stGuaranteed];
    final subs = [l.stReqSub, l.stConfSub, l.stGuarSub];
    return Column(
      children: [
        Row(
          children: [
            for (var i = 0; i < 3; i++) ...[
              if (i > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: i <= step ? MkColors.lime : MkColors.line2,
                  ),
                ),
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= step ? MkColors.lime : MkColors.card2,
                      border: Border.all(
                        color: i <= step ? MkColors.lime : MkColors.line2,
                        width: 2,
                      ),
                    ),
                    child: i < step || (i == 2 && step == 2)
                        ? const Icon(Icons.check, size: 13, color: MkColors.ink)
                        : null,
                  ),
                ],
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            for (var i = 0; i < 3; i++)
              Expanded(
                child: Text(
                  labels[i],
                  textAlign: [
                    TextAlign.start,
                    TextAlign.center,
                    TextAlign.end,
                  ][i],
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: i <= step ? MkColors.text : MkColors.faint,
                  ),
                ),
              ),
          ],
        ),
        if (step >= 0) ...[
          const SizedBox(height: 8),
          Text(
            subs[step],
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: MkColors.sub),
          ),
        ],
      ],
    );
  }
}

/// Striped pitch with white line markings (placeholder for real photos).
class PitchTurf extends StatelessWidget {
  const PitchTurf({super.key, this.height = 76, this.radius = 13, this.child});

  final double height;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: SizedBox(
      height: height,
      child: CustomPaint(
        painter: _TurfPainter(),
        child: child ?? const SizedBox.expand(),
      ),
    ),
  );
}

class _TurfPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final a = Paint()..color = MkColors.brand;
    final b = Paint()..color = const Color(0xFF1D7542);
    final w = size.width / 8;
    for (var i = 0; i < 8; i++) {
      canvas.drawRect(
        Rect.fromLTWH(i * w, 0, w, size.height),
        i.isEven ? a : b,
      );
    }
    final line = Paint()
      ..color = MkColors.text.withValues(alpha: .4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final r = Rect.fromLTWH(5, 5, size.width - 10, size.height - 10);
    canvas
      ..drawRect(r, line)
      ..drawLine(r.topCenter, r.bottomCenter, line)
      ..drawCircle(r.center, size.shortestSide * .15, line);
    final box = Size(r.width * .11, r.height * .4);
    canvas
      ..drawRect(
        Rect.fromLTWH(
          r.left,
          r.center.dy - box.height / 2,
          box.width,
          box.height,
        ),
        line,
      )
      ..drawRect(
        Rect.fromLTWH(
          r.right - box.width,
          r.center.dy - box.height / 2,
          box.width,
          box.height,
        ),
        line,
      );
  }

  @override
  bool shouldRepaint(_TurfPainter oldDelegate) => false;
}

/// Loading / error wrapper used by every screen.
class AsyncBody extends StatelessWidget {
  const AsyncBody({
    super.key,
    required this.loading,
    required this.error,
    required this.onRetry,
    required this.builder,
  });

  final bool loading;
  final Object? error;
  final VoidCallback onRetry;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    if (error != null) {
      return Center(
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
      );
    }
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    return builder(context);
  }
}
