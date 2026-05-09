import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../shared/widgets/cover_image.dart';
import '../../../shared/widgets/share_button.dart';
import '../../../shared/widgets/star_rating.dart';
import '../../../shared/widgets/tag_chip.dart';

class MangaHeader extends StatelessWidget {
  const MangaHeader({
    super.key,
    required this.manga,
    required this.isFavorite,
    required this.onToggleFavorite,
  });

  final Manga manga;
  final bool isFavorite;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: CoverImage(imageUrl: manga.coverUrl),
          ),
          const Gap(AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  manga.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (manga.author != null) ...[
                  const Gap(AppSpacing.xs),
                  Text(
                    manga.author!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
                const Gap(AppSpacing.sm),
                _StatusBadge(status: manga.status),
                const Gap(AppSpacing.sm),
                Row(
                  children: [
                    StarRating(rating: manga.averageRating, size: 16),
                    const Gap(AppSpacing.xs),
                    Text(
                      manga.averageRating.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.ratingYellow,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
                const Gap(AppSpacing.sm),
                Text(
                  '${manga.totalChapters} chương',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const Gap(AppSpacing.sm),
                if (manga.tags.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: manga.tags
                        .take(5)
                        .map((t) => TagChip(label: t))
                        .toList(),
                  ),
                const Gap(AppSpacing.md),
                _ActionRow(
                  isFavorite: isFavorite,
                  onToggleFavorite: onToggleFavorite,
                  mangaTitle: manga.title,
                  shareUrl:
                      'https://mangaapp.example.com/manga/${manga.id}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final MangaStatus status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      MangaStatus.ongoing => AppColors.statusGreen,
      MangaStatus.completed => AppColors.statusBlue,
      MangaStatus.hiatus => AppColors.warning,
      MangaStatus.cancelled => AppColors.error,
    };
    final label = switch (status) {
      MangaStatus.ongoing => 'Đang tiến hành',
      MangaStatus.completed => 'Hoàn thành',
      MangaStatus.hiatus => 'Tạm ngưng',
      MangaStatus.cancelled => 'Đã hủy',
    };
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.isFavorite,
    required this.onToggleFavorite,
    required this.mangaTitle,
    required this.shareUrl,
  });

  final bool isFavorite;
  final VoidCallback onToggleFavorite;
  final String mangaTitle;
  final String shareUrl;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.menu_book, size: 18),
            label: const Text('Đọc ngay'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            ),
          ),
        ),
        const Gap(AppSpacing.sm),
        IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: isFavorite ? Colors.red : AppColors.textSecondary,
          ),
          onPressed: onToggleFavorite,
        ),
        ShareButton(
          title: mangaTitle,
          url: shareUrl,
          compact: true,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }
}
