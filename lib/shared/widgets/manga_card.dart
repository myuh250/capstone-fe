import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import 'cover_image.dart';
import 'star_rating.dart';

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
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CoverImage(imageUrl: manga.coverUrl),
                ),
                if (manga.hasEarlyAccess)
                  Positioned(
                    top: AppSpacing.xs,
                    left: AppSpacing.xs,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                        ),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.bolt, size: 10, color: Colors.white),
                          SizedBox(width: 2),
                          Text(
                            'EARLY',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
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
        ],
      ),
    );
  }

}
