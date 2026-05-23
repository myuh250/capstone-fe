import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/recommendation_providers.dart';
import 'cover_image.dart';

class RecommendationSection extends StatefulWidget {
  const RecommendationSection({
    super.key,
    required this.recommendations,
    required this.onTapManga,
    this.title = 'Recommended for You',
  });

  final List<Recommendation> recommendations;
  final void Function(String mangaId) onTapManga;
  final String title;

  @override
  State<RecommendationSection> createState() => _RecommendationSectionState();
}

class _RecommendationSectionState extends State<RecommendationSection> {
  int _currentPage = 0;
  static const _itemsPerPage = 6;

  int get _pageCount => (widget.recommendations.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    if (widget.recommendations.isEmpty) return const SizedBox.shrink();

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
                widget.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: PageView.builder(
              itemCount: _pageCount,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (_, pageIndex) {
                final start = pageIndex * _itemsPerPage;
                final end = (start + _itemsPerPage)
                    .clamp(0, widget.recommendations.length);
                final pageItems = widget.recommendations.sublist(start, end);

                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (int i = 0; i < pageItems.length; i++) ...[
                        if (i > 0) const Gap(AppSpacing.md),
                        Expanded(
                          child: RecommendationCard(
                            recommendation: pageItems[i],
                            onTap: () =>
                                widget.onTapManga(pageItems[i].manga.id),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        if (_pageCount > 1) ...[
          const Gap(AppSpacing.sm),
          _PageDots(current: _currentPage, total: _pageCount),
        ],
      ],
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : AppColors.divider,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: CoverImage(
                imageUrl: recommendation.manga.coverUrl,
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
            textAlign: TextAlign.center,
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
              textAlign: TextAlign.center,
            ),
        ],
      ),
    );
  }
}
