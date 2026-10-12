import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/providers.dart';

/// Today's bookings at the manager's venue.
final venueTodayProvider = FutureProvider.autoDispose<List<Game>>(
  (ref) => watchGames(ref).venueToday(),
);

/// Players waiting for an in-person ID check.
final verificationQueueProvider = FutureProvider.autoDispose<List<Profile>>(
  (ref) => watchGames(ref).verificationQueue(),
);

/// Whether the scanner opens the camera. Off in widget tests (no camera).
final cameraScanProvider = Provider<bool>((_) => true);
