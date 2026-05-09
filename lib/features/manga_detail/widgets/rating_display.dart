import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class RatingDisplay extends StatelessWidget {
  const RatingDisplay({
    super.key,
    required this.averageRating,
    required this.ratingCount,
    this.userRating,
    this.onRate,
  });

  final double averageRating;
  final int ratingCount;
  final int? userRating;
  final VoidCallback? onRate;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StarDisplay(rating: averageRating),
        const Gap(AppSpacing.sm),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  averageRating.toStringAsFixed(1),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.ratingYellow,
                      ),
                ),
                const SizedBox(width: 4),
                Text(
                  '/ 5',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            Text(
              '$ratingCount đánh giá',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (onRate != null)
          GestureDetector(
            onTap: onRate,
            child: Column(
              children: [
                Icon(
                  userRating != null ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: userRating != null
                      ? AppColors.ratingYellow
                      : AppColors.textSecondary,
                  size: 28,
                ),
                Text(
                  userRating != null ? 'Đã đánh giá' : 'Đánh giá',
                  style: TextStyle(
                    fontSize: 11,
                    color: userRating != null
                        ? AppColors.ratingYellow
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _StarDisplay extends StatelessWidget {
  const _StarDisplay({required this.rating});

  final double rating;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star_rounded, color: AppColors.ratingYellow, size: 18);
        } else if (i < rating) {
          return const Icon(Icons.star_half_rounded, color: AppColors.ratingYellow, size: 18);
        } else {
          return const Icon(Icons.star_outline_rounded, color: AppColors.ratingYellow, size: 18);
        }
      }),
    );
  }
}

class UserRatingBadge extends StatelessWidget {
  const UserRatingBadge({super.key, required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.ratingYellow.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.ratingYellow.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.ratingYellow, size: 14),
          const SizedBox(width: 3),
          Text(
            'Bạn đã đánh giá: $rating/5',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.ratingYellow,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
