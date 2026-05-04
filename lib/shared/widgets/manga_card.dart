import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import 'cover_image.dart';
import 'star_rating.dart';
import 'tag_chip.dart';

class MangaCard extends StatelessWidget {
  const MangaCard({
    super.key,
    required this.manga,
    this.onTap,
    this.showRating = true,
    this.showTags = true,
    this.maxTags = 2,
  });

  final Manga manga;
  final VoidCallback? onTap;
  final bool showRating;
  final bool showTags;
  final int maxTags;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          CoverImage(imageUrl: manga.coverUrl),
          const Gap(AppSpacing.sm),
          Text(
            manga.title,
            style: Theme.of(context).textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (showRating && manga.averageRating > 0) ...[
            const Gap(AppSpacing.xs),
            StarRating(
              rating: manga.averageRating,
              size: 14,
            ),
          ],
          if (showTags && manga.tags.isNotEmpty) ...[
            const Gap(AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: manga.tags
                  .take(maxTags)
                  .map((tag) => TagChip(label: tag))
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }
}
