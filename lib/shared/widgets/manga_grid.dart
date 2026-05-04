import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/utils/constants.dart';
import '../../models/manga.dart';
import 'manga_card.dart';
import 'responsive_builder.dart';

class MangaGrid extends StatelessWidget {
  const MangaGrid({
    super.key,
    required this.items,
    this.onMangaTap,
    this.shrinkWrap = false,
    this.physics,
    this.padding,
  });

  final List<Manga> items;
  final Function(Manga)? onMangaTap;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getMangaGridColumns(context),
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
        childAspectRatio: AppConstants.coverAspectRatio / 1.4,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final manga = items[index];
        return MangaCard(
          manga: manga,
          onTap: onMangaTap != null ? () => onMangaTap!(manga) : null,
        );
      },
    );
  }
}
