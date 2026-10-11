import 'package:flutter/material.dart';

import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/booking_status.dart';
import 'package:matchiko/shared/domain/position.dart';
import 'package:matchiko/shared/domain/rank.dart';

/// Badges, labels and pitch art for the shared domain types.
class PositionBadge extends StatelessWidget {
  const PositionBadge(this.position, {super.key});

  final Position position;

  static const colors = {
    Position.gk: MkColors.sand,
    Position.def: Color(0xFF6CB4EE),
    Position.mid: MkColors.primary,
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
  BookingStatus.guaranteed => (l.stGuaranteed, MkColors.primary),
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
                    color: i <= step ? MkColors.primary : MkColors.line2,
                  ),
                ),
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i <= step ? MkColors.primary : MkColors.card2,
                      border: Border.all(
                        color: i <= step ? MkColors.primary : MkColors.line2,
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
    final a = Paint()..color = MkColors.turf;
    final b = Paint()..color = MkColors.turf2;
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
