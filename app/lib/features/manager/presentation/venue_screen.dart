import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/domain/venue.dart';
import 'package:matchiko/shared/providers.dart';

typedef _VenueData = ({Venue venue, List<Pitch> pitches});

final _venueProvider = FutureProvider.autoDispose<_VenueData>((ref) async {
  final repo = watchGames(ref);
  final r = await Future.wait([repo.venue(), repo.venuePitches()]);
  return (venue: r[0] as Venue, pitches: r[1] as List<Pitch>);
});

/// My venue: opening hours and each pitch's price, size and amenities.
class VenueScreen extends ConsumerWidget {
  const VenueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(backgroundColor: MkColors.bg, title: Text(l.myVenue)),
      body: AsyncView(
        ref.watch(_venueProvider),
        onRetry: () => ref.invalidate(_venueProvider),
        data: (d) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          children: [
            Text(
              d.venue.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            MkLabel(l.openingHours),
            _Hours(d.venue),
            MkLabel(l.pitchesAndPrices),
            for (final p in d.pitches) _PitchCard(p),
          ],
        ),
      ),
    );
  }
}

String _h(int h) => '${(h % 24).toString().padLeft(2, '0')}:00';

class _Hours extends ConsumerWidget {
  const _Hours(this.v);

  final Venue v;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final repo = ref.read(gameRepositoryProvider);
    return MkCard(
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: v.openHour,
              decoration: InputDecoration(labelText: l.opensAt),
              items: [
                for (var h = 6; h < v.closeHour; h++)
                  DropdownMenuItem(value: h, child: Text(_h(h))),
              ],
              onChanged: (h) =>
                  repo.setVenueHours(openHour: h!, closeHour: v.closeHour),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButtonFormField<int>(
              initialValue: v.closeHour,
              decoration: InputDecoration(labelText: l.closesAt),
              items: [
                for (var h = v.openHour + 1; h <= 24; h++)
                  DropdownMenuItem(value: h, child: Text(_h(h))),
              ],
              onChanged: (h) =>
                  repo.setVenueHours(openHour: v.openHour, closeHour: h!),
            ),
          ),
        ],
      ),
    );
  }
}

class _PitchCard extends ConsumerWidget {
  const _PitchCard(this.p);

  final Pitch p;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: MkCard(
        onTap: () => showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (_) => _EditPitch(p),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.name(lang),
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  Text(
                    [
                      '≤ ${p.maxPerSide}v${p.maxPerSide}',
                      if (!p.active) l.pitchHidden,
                    ].join(' · '),
                    style: TextStyle(
                      color: p.active ? MkColors.sub : MkColors.red,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${money(p.priceDa)} ${l.da}${l.perHour}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const Icon(Icons.edit_outlined, color: MkColors.sub, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EditPitch extends ConsumerStatefulWidget {
  const _EditPitch(this.p);

  final Pitch p;

  @override
  ConsumerState<_EditPitch> createState() => _EditPitchState();
}

class _EditPitchState extends ConsumerState<_EditPitch> {
  late final _price = TextEditingController(text: '${widget.p.priceDa}');
  late int _size = widget.p.maxPerSide;
  late final _features = {...widget.p.features};
  late bool _active = widget.p.active;

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  int? get _priceDa {
    final v = int.tryParse(_price.text.trim());
    return v != null && v >= 500 && v <= 50000 ? v : null;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final names = {
      Feature.light: l.fLight,
      Feature.ball: l.fBall,
      Feature.shower: l.fShower,
      Feature.roof: l.fRoof,
      Feature.ref: l.fRef,
    };
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.p.venue,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
            MkLabel(l.pricePerHour),
            TextField(
              controller: _price,
              keyboardType: TextInputType.number,
              textDirection: TextDirection.ltr,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                suffixText: l.da,
                errorText: _priceDa == null ? l.priceInvalid : null,
              ),
            ),
            MkLabel(l.maxSize),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (var n = 3; n <= 11; n++)
                  ChoiceChip(
                    label: Text('${n}v$n'),
                    selected: _size == n,
                    onSelected: (_) => setState(() => _size = n),
                  ),
              ],
            ),
            MkLabel(l.amenities),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in Feature.values)
                  FilterChip(
                    label: Text(names[f]!),
                    selected: _features.contains(f),
                    onSelected: (on) => setState(
                      () => on ? _features.add(f) : _features.remove(f),
                    ),
                  ),
              ],
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l.pitchVisible),
              value: _active,
              onChanged: (v) => setState(() => _active = v),
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: _priceDa == null
                  ? null
                  : () async {
                      final nav = Navigator.of(context);
                      await ref
                          .read(gameRepositoryProvider)
                          .updatePitch(
                            widget.p.id,
                            priceDa: _priceDa!,
                            maxPerSide: _size,
                            features: _features,
                            active: _active,
                          );
                      nav.pop();
                    },
              child: Text(l.save),
            ),
          ],
        ),
      ),
    );
  }
}
