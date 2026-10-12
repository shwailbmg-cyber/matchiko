import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/features/pitches/domain/pitch_filter.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/providers.dart';
import 'package:matchiko/shared/widgets/pitch_row.dart';

/// Pitches matching a search text ('' = all, nearest first).
final _pitchesProvider = FutureProvider.autoDispose.family<List<Pitch>, String>(
  (ref, query) => watchGames(ref).pitches(query: query),
);

/// All pitches with search and filters (size, price, amenities, favourites).
class PitchesScreen extends ConsumerStatefulWidget {
  const PitchesScreen({super.key});

  @override
  ConsumerState<PitchesScreen> createState() => _PitchesScreenState();
}

class _PitchesScreenState extends ConsumerState<PitchesScreen> {
  String _query = '';
  PitchFilter _filter = const PitchFilter();

  void _set(PitchFilter f) => setState(() => _filter = f);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final favorites = ref.watch(favoritesProvider).value ?? const <String>{};
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.allPitches)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: TextField(
              onChanged: (q) => setState(() => _query = q),
              decoration: InputDecoration(
                hintText: l.searchPh,
                prefixIcon: const Icon(Icons.search, color: MkColors.faint),
              ),
            ),
          ),
          _Filters(filter: _filter, onChanged: _set),
          Expanded(
            child: AsyncView(
              ref.watch(_pitchesProvider(_query)),
              onRetry: () => ref.invalidate(_pitchesProvider(_query)),
              data: (all) {
                final list = all
                    .where((p) => _filter.matches(p, favorites))
                    .toList();
                if (list.isEmpty) {
                  return Center(
                    child: MkEmpty(
                      '🏟️',
                      l.noPitchMatch,
                      action: _filter.isEmpty
                          ? null
                          : TextButton(
                              onPressed: () => _set(const PitchFilter()),
                              child: Text(l.clearFilters),
                            ),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: list.length,
                  itemBuilder: (_, i) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: PitchRow(list[i]),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Filters extends StatelessWidget {
  const _Filters({required this.filter, required this.onChanged});

  final PitchFilter filter;
  final ValueChanged<PitchFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget chip(String label, bool on, VoidCallback tap) => Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: FilterChip(
        label: Text(label),
        selected: on,
        showCheckmark: false,
        onSelected: (_) => tap(),
      ),
    );
    void feature(Feature f) {
      final set = {...filter.features};
      set.contains(f) ? set.remove(f) : set.add(f);
      onChanged(filter.copyWith(features: set));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          chip(
            '❤ ${l.favorites}',
            filter.favoritesOnly,
            () => onChanged(
              filter.copyWith(favoritesOnly: !filter.favoritesOnly),
            ),
          ),
          for (final n in [5, 7, 11])
            chip(
              '${n}v$n+',
              filter.minPerSide == n,
              () => onChanged(
                filter.copyWith(minPerSide: filter.minPerSide == n ? null : n),
              ),
            ),
          for (final da in [2000, 2500, 3000])
            chip(
              l.upTo(money(da)),
              filter.maxPriceDa == da,
              () => onChanged(
                filter.copyWith(
                  maxPriceDa: filter.maxPriceDa == da ? null : da,
                ),
              ),
            ),
          for (final (f, label) in [
            (Feature.light, l.fLight),
            (Feature.roof, l.fRoof),
            (Feature.shower, l.fShower),
          ])
            chip(label, filter.features.contains(f), () => feature(f)),
        ],
      ),
    );
  }
}
