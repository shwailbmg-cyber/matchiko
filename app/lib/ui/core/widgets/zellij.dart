import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/mk_colors.dart';

/// Sand-gold khatam (8-point star) tile pattern, the prototype's `--zel`
/// background. Used behind heroes and cards with the `.zel` class.
class ZellijPainter extends CustomPainter {
  const ZellijPainter({this.tile = 56, this.opacity = .16});

  final double tile;
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = MkColors.sand.withValues(alpha: opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1 * tile / 56;
    final k = tile / 56;
    for (var y = 0.0; y < size.height; y += tile) {
      for (var x = 0.0; x < size.width; x += tile) {
        canvas
          ..save()
          ..translate(x, y)
          ..scale(k);
        const sq = Rect.fromLTWH(16, 16, 24, 24);
        canvas
          ..drawRect(sq, p)
          ..save()
          ..translate(28, 28)
          ..rotate(math.pi / 4)
          ..translate(-28, -28)
          ..drawRect(sq, p)
          ..restore()
          ..drawCircle(const Offset(28, 28), 4, p);
        for (final l in _lines) {
          canvas.drawLine(l.$1, l.$2, p);
        }
        canvas.restore();
      }
    }
  }

  static const _lines = [
    (Offset(0, 0), Offset(16, 16)),
    (Offset(56, 0), Offset(40, 16)),
    (Offset(0, 56), Offset(16, 40)),
    (Offset(56, 56), Offset(40, 40)),
    (Offset(28, 0), Offset(28, 11)),
    (Offset(28, 56), Offset(28, 45)),
    (Offset(0, 28), Offset(11, 28)),
    (Offset(56, 28), Offset(45, 28)),
  ];

  @override
  bool shouldRepaint(ZellijPainter old) =>
      old.tile != tile || old.opacity != opacity;
}

/// Puts the zellij pattern behind [child], fading out towards the bottom-left
/// like the prototype's masked `.zel::before`.
class Zellij extends StatelessWidget {
  const Zellij({super.key, required this.child, this.opacity = .16});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: ShaderMask(
            shaderCallback: (r) => const LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.black, Colors.transparent],
              stops: [.1, .7],
            ).createShader(r),
            blendMode: BlendMode.dstIn,
            child: CustomPaint(painter: ZellijPainter(opacity: opacity)),
          ),
        ),
        child,
      ],
    );
  }
}
