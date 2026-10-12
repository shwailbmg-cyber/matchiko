import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:matchiko/core/theme/mk_colors.dart';
import 'package:matchiko/l10n/gen/app_localizations.dart';
import 'package:matchiko/shared/providers.dart';

/// Heart that adds or removes a pitch from my favourites.
class FavoriteButton extends ConsumerWidget {
  const FavoriteButton(this.pitchId, {super.key, this.size = 24});

  final String pitchId;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(favoritesProvider).value?.contains(pitchId) ?? false;
    final l = AppLocalizations.of(context);
    return IconButton(
      visualDensity: VisualDensity.compact,
      iconSize: size,
      tooltip: on ? l.removeFavorite : l.addFavorite,
      isSelected: on,
      onPressed: () =>
          ref.read(gameRepositoryProvider).setFavorite(pitchId, favorite: !on),
      icon: const Icon(Icons.favorite_border, color: MkColors.sub),
      selectedIcon: const Icon(Icons.favorite, color: MkColors.terra),
    );
  }
}
