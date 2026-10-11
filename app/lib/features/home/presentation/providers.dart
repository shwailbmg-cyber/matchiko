import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/profile.dart';
import 'package:matchiko/shared/providers.dart';

typedef HomeData = ({Profile me, int live, List<Game> openGames});

final homeProvider = FutureProvider.autoDispose<HomeData>((ref) async {
  final repo = watchGames(ref);
  final r = await Future.wait([
    repo.me(),
    repo.liveSearching(),
    repo.openGames(),
  ]);
  return (
    me: r[0] as Profile,
    live: r[1] as int,
    openGames: r[2] as List<Game>,
  );
});

/// Pitches matching a search text ('' = all, nearest first).
final pitchesProvider = FutureProvider.autoDispose.family<List<Pitch>, String>(
  (ref, query) => watchGames(ref).pitches(query: query),
);
