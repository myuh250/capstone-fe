import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ReadingProgressBar extends StatelessWidget {
  const ReadingProgressBar({
    super.key,
    required this.chaptersRead,
    required this.totalChapters,
    this.height = 4.0,
  });

  final int chaptersRead;
  final int totalChapters;
  final double height;

  double get _progress {
    if (totalChapters == 0) return 0;
    return (chaptersRead / totalChapters).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          child: LinearProgressIndicator(
            value: _progress,
            minHeight: height,
            backgroundColor: AppColors.divider,
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$chaptersRead / $totalChapters chapters',
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
