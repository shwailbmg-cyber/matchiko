/// What a Matchiko QR code holds. Plain text, so any scanner can read it.
///
/// - `matchiko:booking:<token>` — the booking ticket (random server token).
/// - `matchiko:player:<handle>` — a player, for verification and check-in.
sealed class QrPayload {
  const QrPayload();

  static const _prefix = 'matchiko:';

  static QrPayload? parse(String raw) {
    final parts = raw.trim().split(':');
    if (parts.length != 3 || '${parts[0]}:' != _prefix || parts[2].isEmpty) {
      return null;
    }
    return switch (parts[1]) {
      'booking' => BookingQr(parts[2]),
      'player' => PlayerQr(parts[2]),
      _ => null,
    };
  }
}

class BookingQr extends QrPayload {
  const BookingQr(this.token);
  final String token;

  @override
  String toString() => '${QrPayload._prefix}booking:$token';
}

class PlayerQr extends QrPayload {
  const PlayerQr(this.handle);
  final String handle;

  @override
  String toString() => '${QrPayload._prefix}player:$handle';
}
