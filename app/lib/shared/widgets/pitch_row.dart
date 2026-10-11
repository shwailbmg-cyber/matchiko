import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:matchiko/core/format.dart';
import 'package:matchiko/core/router/routes.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/core/theme/mk_theme.dart';
import 'package:matchiko/core/widgets/mk_widgets.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/domain/pitch.dart';
import 'package:matchiko/shared/widgets/badges.dart';
import 'package:matchiko/shared/widgets/favorite_button.dart';

/// Pitch card used in lists: turf, name, distance, rating, size, price.
class PitchRow extends StatelessWidget {
  const PitchRow(this.pitch, {super.key});

  final Pitch pitch;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    return MkCard(
      padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 16, 10),
      onTap: () => context.push(Routes.pitch(pitch.id)),
      child: Row(
        children: [
          const SizedBox(width: 76, child: PitchTurf()),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pitch.name(lang),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${pitch.district} · ${pitch.km} ${l.km}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: MkColors.sub, fontSize: 12.5),
                ),
                const SizedBox(height: 4),
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Icon(Icons.star, size: 14, color: MkColors.sand),
                    Text(
                      ' ${pitch.rating}  ',
                      style: const TextStyle(
                        color: MkColors.sand,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                    MkTag('≤ ${pitch.maxPerSide}v${pitch.maxPerSide}'),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FavoriteButton(pitch.id, size: 20),
              Text(
                money(pitch.priceDa),
                style: const TextStyle(
                  fontFamily: MkFonts.display,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
              Text(
                '${l.da}${l.perHour}',
                style: const TextStyle(color: MkColors.sub, fontSize: 11.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
