import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import 'package:matchiko/l10n/gen/app_localizations.dart';

/// "Today", "Tomorrow" or a short weekday ("Thu").
String dayLabel(BuildContext context, DateTime t, {DateTime? now}) {
  final l = AppLocalizations.of(context);
  final n = now ?? DateTime.now();
  final d = DateTime(
    t.year,
    t.month,
    t.day,
  ).difference(DateTime(n.year, n.month, n.day)).inDays;
  if (d == 0) return l.today;
  if (d == 1) return l.tomorrow;
  return DateFormat.E(_locale(context)).format(t);
}

/// "21:00" (24 h, as in Algeria).
String hhmm(DateTime t) =>
    '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

/// "2 500" with a narrow space, like the prototype.
String money(int da) {
  final s = da.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(' ');
    b.write(s[i]);
  }
  return b.toString();
}

String _locale(BuildContext context) =>
    Localizations.localeOf(context).languageCode;
