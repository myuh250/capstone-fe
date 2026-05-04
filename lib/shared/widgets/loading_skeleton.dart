import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/constants.dart';

class LoadingSkeleton extends StatelessWidget {
  const LoadingSkeleton({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: borderRadius ??
              BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
    );
  }
}

class MangaCardSkeleton extends StatelessWidget {
  const MangaCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AspectRatio(
          aspectRatio: AppConstants.coverAspectRatio,
          child: LoadingSkeleton(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.circular(AppSpacing.coverRadius),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        const LoadingSkeleton(
          width: double.infinity,
          height: 16,
        ),
        const SizedBox(height: AppSpacing.xs),
        const LoadingSkeleton(
          width: 80,
          height: 12,
        ),
      ],
    );
  }
}

class MangaGridSkeleton extends StatelessWidget {
  const MangaGridSkeleton({
    super.key,
    this.itemCount = 12,
    this.crossAxisCount = 2,
  });

  final int itemCount;
  final int crossAxisCount;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(AppSpacing.lg),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: AppSpacing.lg,
        crossAxisSpacing: AppSpacing.lg,
        childAspectRatio: AppConstants.coverAspectRatio / 1.4,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) => const MangaCardSkeleton(),
    );
  }
}
