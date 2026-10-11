import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/shared/domain/auth_repository.dart';
import 'package:matchiko/shared/domain/game_repository.dart';
import 'package:matchiko/shared/domain/profile.dart';

/// The data source for games, pitches and the signed-in player.
/// `main()` overrides it with the demo or Supabase implementation.
final gameRepositoryProvider = Provider<GameRepository>(
  (ref) => throw UnimplementedError('Override gameRepositoryProvider'),
);

/// Ticks when repository data changes. Data providers watch it (through
/// [watchGames]) so every screen refreshes after any change.
final gamesRevisionProvider = StreamProvider<int>(
  (ref) => ref.watch(gameRepositoryProvider).changes,
);

/// The repository, refetching whenever its data changes.
GameRepository watchGames(Ref ref) {
  ref.watch(gamesRevisionProvider);
  return ref.watch(gameRepositoryProvider);
}

final meProvider = FutureProvider.autoDispose<Profile>(
  (ref) => watchGames(ref).me(),
);

/// Sign-in backend. `main()` overrides it (demo or Supabase).
final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => throw UnimplementedError('Override authRepositoryProvider'),
);

/// Who is signed in (null = signed out). Emits on every sign-in and out.
final sessionProvider = StreamProvider<SessionUser?>((ref) async* {
  final auth = ref.watch(authRepositoryProvider);
  yield auth.currentUser;
  yield* auth.changes;
});
