import 'package:flutter/material.dart';
import 'package:qr/qr.dart' as qr;

import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/qr_payload.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';

/// White booking ticket with the QR code (prototype `.ticket`).
///
/// The QR holds the booking's random server token (see [BookingQr]).
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
          Text(k, style: const TextStyle(color: Color(0xFF5A5480))),
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
            QrCode('${BookingQr(game.code)}'),
            const SizedBox(height: 14),
            Text(
              l.code.toUpperCase(),
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF5A5480),
                letterSpacing: 1,
              ),
            ),
            SelectableText(
              game.code,
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              style: const TextStyle(
                fontFamily: MkFonts.display,
                fontWeight: FontWeight.w800,
                fontSize: 18,
                letterSpacing: 1,
              ),
            ),
            const Divider(height: 28, color: Color(0x2E14072E)),
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

/// A real, scannable QR code for [data] (black on the white ticket).
class QrCode extends StatelessWidget {
  const QrCode(this.data, {super.key, this.size = 176});

  final String data;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: 'QR',
    child: CustomPaint(size: Size.square(size), painter: _QrPainter(data)),
  );
}

class _QrPainter extends CustomPainter {
  _QrPainter(this.data)
    : image = qr.QrImage(qr.QrCode(payload: qr.QrPayload.fromString(data)));

  final String data;
  final qr.QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final n = image.moduleCount;
    final c = size.width / n;
    final dark = Paint()..color = MkColors.bg;
    for (var y = 0; y < n; y++) {
      for (var x = 0; x < n; x++) {
        if (image.isDark(y, x)) {
          canvas.drawRect(Rect.fromLTWH(x * c, y * c, c + .3, c + .3), dark);
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter old) => old.data != data;
}
