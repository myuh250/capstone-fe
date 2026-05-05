import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/chapter.dart';
import '../../../providers/manga_providers.dart';
import '../../../shared/widgets/error_view.dart';
import '../../../shared/widgets/loading_skeleton.dart';
import 'chapter_list_tile.dart';

class ChapterList extends ConsumerWidget {
  const ChapterList({
    super.key,
    required this.mangaId,
    required this.onTapChapter,
  });

  final String mangaId;
  final void Function(Chapter chapter) onTapChapter;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(chapterListProvider(mangaId));

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
                    ? 'Danh sách chương'
                    : 'Danh sách chương (${state.chapters.length})',
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
                    ? 'Sắp xếp mới nhất'
                    : 'Sắp xếp cũ nhất',
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
            message: 'Không thể tải danh sách chương.',
            onRetry: () =>
                ref.read(chapterListProvider(mangaId).notifier).refresh(),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.chapters.length,
            itemBuilder: (context, index) {
              return ChapterListTile(
                key: ValueKey(state.chapters[index].id),
                chapter: state.chapters[index],
                onTap: () => onTapChapter(state.chapters[index]),
              );
            },
          ),
        const Gap(AppSpacing.lg),
      ],
    );
  }
}
