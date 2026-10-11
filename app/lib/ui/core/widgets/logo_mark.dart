import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mk_colors.dart';

/// Zellij 8-point star (two rotated squares) with a pentagon "ball" inside.
/// Port of `logoMark()` in `design/prototype/matchiko-core.js` (40×40 viewBox).
class LogoMark extends StatelessWidget {
  const LogoMark({super.key, this.size = 34});

  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40);
    final fill = Paint()..color = MkColors.primary;
    final square = RRect.fromRectAndRadius(
      const Rect.fromLTWH(8, 8, 24, 24),
      const Radius.circular(2.5),
    );
    canvas.drawRRect(square, fill);
    canvas
      ..save()
      ..translate(20, 20)
      ..rotate(math.pi / 4)
      ..translate(-20, -20)
      ..drawRRect(square, fill)
      ..restore();
    canvas.drawCircle(const Offset(20, 20), 8.6, Paint()..color = MkColors.bg);
    final ball = Path()
      ..moveTo(20, 14.6)
      ..lineTo(25.1, 18.3)
      ..lineTo(23.1, 24.3)
      ..lineTo(16.9, 24.3)
      ..lineTo(14.9, 18.3)
      ..close();
    canvas.drawPath(
      ball,
      Paint()
        ..color = MkColors.primary
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}

/// Logo mark + "matchi**ko**" wordmark (always LTR, also in Arabic).
class MkLogo extends StatelessWidget {
  const MkLogo({super.key, this.markSize = 34, this.fontSize = 23});

  final double markSize;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontWeight: FontWeight.w900,
      fontSize: fontSize,
      letterSpacing: -.5,
      color: MkColors.text,
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: TextDirection.ltr,
      children: [
        if (markSize > 0) ...[
          LogoMark(size: markSize),
          const SizedBox(width: 8),
        ],
        Text.rich(
          TextSpan(
            text: 'matchi',
            children: const [
              TextSpan(
                text: 'ko',
                style: TextStyle(color: MkColors.primary),
              ),
            ],
          ),
          style: style,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
