import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/env.dart';
import 'package:matchiko/core/router/router.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/providers.dart';

/// Push notifications through Firebase Cloud Messaging. The server writes
/// the inbox and the `push` Edge Function sends; the app only keeps this
/// device's token on the server. Off without Firebase config, and on the
/// web (no service worker yet).
abstract final class Push {
  static bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;
  static String get _platform => _ios ? 'ios' : 'android';
  static String get _apiKey =>
      _ios ? Env.firebaseIosApiKey : Env.firebaseAndroidApiKey;
  static String get _appId =>
      _ios ? Env.firebaseIosAppId : Env.firebaseAndroidAppId;

  static bool get enabled =>
      !kIsWeb &&
      Env.firebaseProjectId.isNotEmpty &&
      Env.firebaseSenderId.isNotEmpty &&
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty;

  static Future<void> init() async {
    if (!enabled) return;
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: _apiKey,
        appId: _appId,
        messagingSenderId: Env.firebaseSenderId,
        projectId: Env.firebaseProjectId,
        iosBundleId: 'dz.bmgdev.matchiko',
      ),
    );
  }

  /// Call before signing out, so this device stops getting the old
  /// account's notifications.
  static Future<void> forget(GameRepository repo) async {
    if (!enabled) return;
    final m = FirebaseMessaging.instance;
    try {
      final token = await m.getToken();
      if (token != null) await repo.unregisterPushToken(token);
    } on Object {
      // Offline: deleting the token is enough, the `push` function drops
      // dead tokens on the next send.
    }
    await m.deleteToken();
  }
}

/// While someone is signed in: register the token (and its refreshes), and
/// open the game when a notification is tapped. Watched by the app root.
final pushProvider = Provider<void>((ref) {
  if (!Push.enabled) return;
  if (ref.watch(sessionProvider).value == null) return;
  final repo = ref.watch(gameRepositoryProvider);
  final m = FirebaseMessaging.instance;

  void open(RemoteMessage msg) {
    final id = msg.data['game_id'];
    if (id is String && id.isNotEmpty) {
      ref.read(routerProvider).push(Routes.game(id));
    }
  }

  Future<void> register() async {
    final s = await m.requestPermission();
    if (s.authorizationStatus == AuthorizationStatus.denied) return;
    final token = await m.getToken();
    if (token != null) await repo.registerPushToken(token, Push._platform);
    final first = await m.getInitialMessage();
    if (first != null) open(first);
  }

  unawaited(register());
  final subs = [
    m.onTokenRefresh.listen((t) => repo.registerPushToken(t, Push._platform)),
    FirebaseMessaging.onMessageOpenedApp.listen(open),
    // In the foreground the inbox just refreshes.
    FirebaseMessaging.onMessage.listen(
      (_) => ref.invalidate(notificationsProvider),
    ),
  ];
  ref.onDispose(() {
    for (final s in subs) {
      s.cancel();
    }
  });
});
