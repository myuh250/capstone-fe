import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/chapter.dart';

class ReaderBottomBar extends StatelessWidget {
  const ReaderBottomBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.previousChapter,
    required this.nextChapter,
    required this.onPageChanged,
    required this.onPreviousChapter,
    required this.onNextChapter,
  });

  final int currentPage;
  final int totalPages;
  final Chapter? previousChapter;
  final Chapter? nextChapter;
  final void Function(int page) onPageChanged;
  final VoidCallback? onPreviousChapter;
  final VoidCallback? onNextChapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md + MediaQuery.of(context).padding.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _ChapterNavButton(
                icon: Icons.skip_previous,
                label: previousChapter?.displayNumber ?? 'Đầu',
                onTap: onPreviousChapter,
              ),
              Text(
                '$currentPage / $totalPages',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
              _ChapterNavButton(
                icon: Icons.skip_next,
                label: nextChapter?.displayNumber ?? 'Cuối',
                onTap: onNextChapter,
                isNext: true,
              ),
            ],
          ),
          const Gap(AppSpacing.sm),
          SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              activeTrackColor: AppColors.primary,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.primary,
              overlayColor: AppColors.primary.withOpacity(0.2),
            ),
            child: Slider(
              value: currentPage.toDouble(),
              min: 1,
              max: totalPages > 0 ? totalPages.toDouble() : 1,
              onChanged: (v) => onPageChanged(v.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterNavButton extends StatelessWidget {
  const _ChapterNavButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isNext = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isNext) ...[
            Icon(icon, color: Colors.white70, size: 20),
            const Gap(AppSpacing.xs),
          ],
          Text(
            label,
            style: TextStyle(
              color: onTap != null ? Colors.white : Colors.white38,
              fontSize: 13,
            ),
          ),
          if (isNext) ...[
            const Gap(AppSpacing.xs),
            Icon(icon, color: Colors.white70, size: 20),
          ],
        ],
      ),
    );
  }
}
