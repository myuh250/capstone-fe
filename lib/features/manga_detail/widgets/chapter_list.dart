import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/chapter.dart';
import '../../../providers/manga_providers.dart';
import '../../../providers/subscription_providers.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'chapter_list_tile.dart';

class ChapterList extends ConsumerWidget {
  const ChapterList({
    super.key,
    required this.mangaId,
    required this.onTapChapter,
    this.mangaTitle = '',
    this.coverUrl = '',
  });

  final String mangaId;
  final void Function(Chapter chapter) onTapChapter;
  final String mangaTitle;
  final String coverUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chapterListProvider(mangaId));
    final isPremium = ref.watch(isPremiumProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                state.isLoading
                    ? 'Chapter List'
                    : 'Chapter List (${state.chapters.length})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              IconButton(
                icon: Icon(
                  state.ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                onPressed: () =>
                    ref.read(chapterListProvider(mangaId).notifier).toggleSort(),
                tooltip: state.ascending
                    ? 'Sort Newest First'
                    : 'Sort Oldest First',
              ),
            ],
          ),
        ),
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: LoadingSkeleton(width: double.infinity, height: 200),
          )
        else if (state.error != null)
          ErrorView(
            message: 'Unable to load chapter list.',
            onRetry: () =>
                ref.read(chapterListProvider(mangaId).notifier).refresh(),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              itemCount: state.chapters.length,
              itemBuilder: (context, index) {
                return ChapterListTile(
                  key: ValueKey(state.chapters[index].id),
                  chapter: state.chapters[index],
                  onTap: () => onTapChapter(state.chapters[index]),
                  isPremium: isPremium,
                  mangaId: mangaId,
                  mangaTitle: mangaTitle,
                  coverUrl: coverUrl,
                );
              },
            ),
          ),
        const Gap(AppSpacing.lg),
      ],
    );
  }
}
