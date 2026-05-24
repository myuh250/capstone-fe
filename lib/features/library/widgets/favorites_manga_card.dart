import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../shared/widgets/cover_image.dart';
import '../../../shared/widgets/tag_chip.dart';

class FavoritesMangaCard extends StatelessWidget {
  const FavoritesMangaCard({
    super.key,
    required this.manga,
    required this.onTap,
    required this.onRemove,
  });

  final Manga manga;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusMd),
              ),
              child: CoverImage(
                imageUrl: manga.coverUrl,
                width: 64,
                height: 92,
              ),
            ),
            const Gap(AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Gap(4),
                  if (manga.author != null)
                    Text(
                      manga.author!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const Gap(AppSpacing.xs),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: manga.tags
                        .take(3)
                        .map((t) => TagChip(label: t))
                        .toList(),
                  ),
                  const Gap(AppSpacing.xs),
                  Row(
                    children: [
                      _StatusDot(status: manga.status),
                      const SizedBox(width: 4),
                      Text(
                        manga.status.displayName,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${manga.totalChapters} ch.',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.favorite, color: AppColors.error),
              onPressed: onRemove,
              tooltip: 'Remove from Favorites',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final MangaStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MangaStatus.ongoing => AppColors.statusGreen,
      MangaStatus.completed => AppColors.statusBlue,
      MangaStatus.hiatus => AppColors.warning,
      MangaStatus.cancelled => AppColors.error,
    };
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
