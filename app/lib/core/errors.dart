import 'package:flutter/material.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';

/// App-wide snackbar host (set on MaterialApp), so any failed action can
/// tell the user without each button handling errors itself.
final messengerKey = GlobalKey<ScaffoldMessengerState>();

/// True when [e] looks like "no network" (Dart IO, http, Supabase).
bool isOffline(Object e) {
  final s = e.toString();
  return const [
    'SocketException',
    'Failed host lookup',
    'ClientException',
    'Connection refused',
    'Network is unreachable',
    'AuthRetryableFetchException',
    'XMLHttpRequest error',
  ].any(s.contains);
}

/// Short message for [e] in the app language.
String errorText(AppLocalizations l, Object e) =>
    isOffline(e) ? l.offline : l.genericError;

/// Shows [e] as a snackbar. Used for uncaught errors from button actions
/// (main.dart). The server already refused anything invalid.
void showError(Object e) {
  final m = messengerKey.currentState;
  final ctx = messengerKey.currentContext;
  if (m == null || ctx == null) return;
  final l = AppLocalizations.of(ctx);
  m
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(errorText(l, e))));
}
