import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/shared/domain/game.dart';
import 'package:matchiko/shared/providers.dart';

/// My upcoming and past games.
final myGamesProvider =
    FutureProvider.autoDispose<({List<Game> upcoming, List<Game> past})>((
      ref,
    ) async {
      final repo = watchGames(ref);
      final r = await Future.wait([repo.myUpcoming(), repo.myPast()]);
      return (upcoming: r[0], past: r[1]);
    });
