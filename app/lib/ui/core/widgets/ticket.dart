import 'package:flutter/material.dart';

import '../../../domain/models/game.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../format.dart';
import '../theme/mk_colors.dart';
import '../theme/mk_theme.dart';

/// White booking ticket with the QR code (prototype `.ticket`).
///
/// The QR drawing is a deterministic placeholder from the booking code, like
/// the prototype; the real scannable QR (random server token) comes with the
/// manager camera scan in M3.
class Ticket extends StatelessWidget {
  const Ticket(this.game, {super.key});

  final Game game;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    Widget kv(String k, String v) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(k, style: const TextStyle(color: Color(0xFF4A6B57))),
          const Spacer(),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 10),
      decoration: BoxDecoration(
        color: MkColors.text,
        borderRadius: BorderRadius.circular(24),
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: MkColors.ink, fontSize: 14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPaint(
              size: const Size.square(176),
              painter: _QrPainter(game.code),
            ),
            const SizedBox(height: 14),
            Text(
              l.code.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4A6B57),
                letterSpacing: 1,
              ),
            ),
            Text(
              game.code,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: MkFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: 26,
                letterSpacing: 2,
              ),
            ),
            const Divider(height: 28, color: Color(0x2E04200F)),
            kv(l.pitch, game.pitch.name(lang)),
            kv(
              l.when,
              '${dayLabel(context, game.startsAt)} · ${hhmm(game.startsAt)}',
            ),
            kv(l.format, '${game.perSide}v${game.perSide}'),
            kv(l.perPlayer, '${money(game.share.perPlayer)} ${l.da}'),
          ],
        ),
      ),
    );
  }
}

Future<void> showTicket(BuildContext context, Game game) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Ticket(game),
      ),
    );

class _QrPainter extends CustomPainter {
  _QrPainter(this.seed);

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    const n = 25;
    final c = size.width / n;
    final dark = Paint()..color = MkColors.bg;
    final light = Paint()..color = MkColors.text;
    var h = 0;
    for (final u in seed.codeUnits) {
      h = (h * 31 + u) & 0x7fffffff;
    }
    bool finder(int x, int y) =>
        (x < 8 && y < 8) || (x >= n - 8 && y < 8) || (x < 8 && y >= n - 8);
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        h = (h * 1103515245 + 12345) & 0x7fffffff;
        if (!finder(x, y) && (h >> 16) & 1 == 1) {
          canvas.drawRect(Rect.fromLTWH(x * c, y * c, c + .3, c + .3), dark);
        }
      }
    }
    for (final (fx, fy) in [(0, 0), (n - 7, 0), (0, n - 7)]) {
      canvas
        ..drawRect(Rect.fromLTWH(fx * c, fy * c, 7 * c, 7 * c), dark)
        ..drawRect(
          Rect.fromLTWH((fx + 1) * c, (fy + 1) * c, 5 * c, 5 * c),
          light,
        )
        ..drawRect(
          Rect.fromLTWH((fx + 2) * c, (fy + 2) * c, 3 * c, 3 * c),
          dark,
        );
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.seed != seed;
}
