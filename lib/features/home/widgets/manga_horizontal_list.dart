import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../shared/widgets/manga_card.dart';

class MangaHorizontalList extends StatelessWidget {
  const MangaHorizontalList({
    super.key,
    required this.items,
    this.onTapManga,
    this.cardWidth = 130,
  });

  final List<Manga> items;
  final void Function(Manga manga)? onTapManga;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: cardWidth * (3 / 2) + 70,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final manga = items[index];
          return SizedBox(
            width: cardWidth,
            child: MangaCard(
              manga: manga,
              onTap: onTapManga != null ? () => onTapManga!(manga) : null,
            ),
          );
        },
      ),
    );
  }
}
