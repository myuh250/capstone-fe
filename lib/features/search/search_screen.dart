import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/search_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/loading_skeleton.dart';
import '../../shared/widgets/manga_grid.dart';
import 'widgets/filter_bottom_sheet.dart';
import 'widgets/filter_chip_bar.dart';
import 'widgets/search_text_field.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(searchQueryProvider);
    final filters = ref.watch(searchFiltersProvider);
    final resultsAsync = ref.watch(searchResultsProvider);

    return Scaffold(
      appBar: AppBar(
        title: SearchTextField(
          initialValue: query,
          onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
        ),
        titleSpacing: AppSpacing.sm,
        actions: [const SizedBox(width: AppSpacing.sm)],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Gap(AppSpacing.sm),
          FilterChipBar(
            filters: filters,
            onFilterTap: () => FilterBottomSheet.show(context),
            onSortTap: () => FilterBottomSheet.show(context),
          ),
          const Gap(AppSpacing.sm),
          Expanded(
            child: resultsAsync.when(
              data: (mangas) {
                if (mangas.isEmpty) {
                  return EmptyState(
                    icon: Icons.search_off,
                    message: query.isNotEmpty
                        ? 'Không có manga nào khớp với "$query"'
                        : 'Hãy nhập từ khóa để tìm kiếm',
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      child: Text(
                        '${mangas.length} kết quả',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                    const Gap(AppSpacing.sm),
                    Expanded(
                      child: MangaGrid(
                        items: mangas,
                        onMangaTap: (manga) =>
                            context.push(RouteNames.mangaDetail(manga.id)),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const MangaGridSkeleton(crossAxisCount: 2),
              error: (e, _) => ErrorView(
                message: 'Không thể tải kết quả tìm kiếm.',
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
