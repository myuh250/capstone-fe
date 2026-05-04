import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class StarRating extends StatelessWidget {
  const StarRating({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 16,
    this.showValue = true,
    this.onRatingChanged,
  });

  final double rating;
  final int maxRating;
  final double size;
  final bool showValue;
  final ValueChanged<double>? onRatingChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxRating, (index) {
          return GestureDetector(
            onTap: onRatingChanged != null
                ? () => onRatingChanged!(index + 1.0)
                : null,
            child: Icon(
              _getIconData(index),
              size: size,
              color: AppColors.ratingYellow,
            ),
          );
        }),
        if (showValue) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            rating.toStringAsFixed(1),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ],
    );
  }

  IconData _getIconData(int index) {
    final value = index + 1;
    if (rating >= value) {
      return Icons.star;
    } else if (rating >= value - 0.5) {
      return Icons.star_half;
    } else {
      return Icons.star_outline;
    }
  }
}
