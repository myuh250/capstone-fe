import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/recommendation_providers.dart';
import 'cover_image.dart';

class RecommendationSection extends StatelessWidget {
  const RecommendationSection({
    super.key,
    required this.recommendations,
    required this.onTapManga,
    this.title = 'Đề xuất cho bạn',
  });

  final List<Recommendation> recommendations;
  final void Function(String mangaId) onTapManga;
  final String title;

  @override
  Widget build(BuildContext context) {
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.md,
          ),
          child: Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                color: AppColors.primary,
                size: 18,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            itemCount: recommendations.length,
            separatorBuilder: (_, __) => const Gap(AppSpacing.md),
            itemBuilder: (_, i) {
              final rec = recommendations[i];
              return RecommendationCard(
                recommendation: rec,
                onTap: () => onTapManga(rec.manga.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.onTap,
  });

  final Recommendation recommendation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: CoverImage(
                  imageUrl: recommendation.manga.coverUrl,
                  width: 110,
                ),
              ),
            ),
            const Gap(AppSpacing.xs),
            Text(
              recommendation.manga.title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (recommendation.becauseOf != null)
              Text(
                recommendation.becauseOf!,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
      ),
    );
  }
}
