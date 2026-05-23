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
import '../../shared/widgets/manga_card.dart';
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
    final currentPage = ref.watch(searchPageProvider);

    return Scaffold(
      appBar: AppBar(
        title: SearchTextField(
          initialValue: query,
          onChanged: (q) {
            ref.read(searchQueryProvider.notifier).state = q;
            ref.read(searchPageProvider.notifier).state = 0;
          },
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
              data: (result) {
                if (result.items.isEmpty && currentPage == 0) {
                  return EmptyState(
                    icon: Icons.search_off,
                    message: query.isNotEmpty
                        ? 'No manga matching "$query"'
                        : 'Browse all manga',
                  );
                }
                return Column(
                  children: [
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: AppSpacing.md,
                          crossAxisSpacing: AppSpacing.md,
                          childAspectRatio: 0.52,
                        ),
                        itemCount: result.items.length,
                        itemBuilder: (_, i) {
                          final manga = result.items[i];
                          return MangaCard(
                            manga: manga,
                            onTap: () => context.push(
                              RouteNames.mangaDetail(manga.slug ?? manga.id),
                            ),
                          );
                        },
                      ),
                    ),
                    _PaginationBar(
                      currentPage: currentPage,
                      totalPages: result.totalPages,
                      onPageChanged: (page) =>
                          ref.read(searchPageProvider.notifier).state = page,
                    ),
                  ],
                );
              },
              loading: () => const MangaGridSkeleton(crossAxisCount: 6),
              error: (e, _) => ErrorView(
                message: 'Failed to load results.',
                onRetry: () => ref.invalidate(searchResultsProvider),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaginationBar extends StatefulWidget {
  const _PaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
  });

  final int currentPage;
  final int totalPages;
  final void Function(int page) onPageChanged;

  @override
  State<_PaginationBar> createState() => _PaginationBarState();
}

class _PaginationBarState extends State<_PaginationBar> {
  late TextEditingController _controller;

  bool get _isFirst => widget.currentPage <= 0;
  bool get _isLast => widget.currentPage >= widget.totalPages - 1;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: '${widget.currentPage + 1}');
  }

  @override
  void didUpdateWidget(covariant _PaginationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentPage != widget.currentPage) {
      _controller.text = '${widget.currentPage + 1}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    final clamped = page.clamp(0, widget.totalPages - 1);
    widget.onPageChanged(clamped);
  }

  void _submitPage() {
    final value = int.tryParse(_controller.text);
    if (value != null && value >= 1) {
      _goToPage(value - 1);
    } else {
      _controller.text = '${widget.currentPage + 1}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.lg,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _isFirst ? null : () => _goToPage(0),
            icon: const Icon(Icons.first_page),
            tooltip: 'First page',
            color: AppColors.textPrimary,
            disabledColor: AppColors.divider,
          ),
          IconButton(
            onPressed: _isFirst
                ? null
                : () => _goToPage(widget.currentPage - 1),
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Previous page',
            color: AppColors.textPrimary,
            disabledColor: AppColors.divider,
          ),
          const Gap(AppSpacing.sm),
          SizedBox(
            width: 56,
            height: 36,
            child: TextField(
              controller: _controller,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                filled: true,
                fillColor: AppColors.surfaceAlt,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _submitPage(),
            ),
          ),
          Text(
            ' / ${widget.totalPages}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Gap(AppSpacing.sm),
          IconButton(
            onPressed: _isLast
                ? null
                : () => _goToPage(widget.currentPage + 1),
            icon: const Icon(Icons.chevron_right),
            tooltip: 'Next page',
            color: AppColors.textPrimary,
            disabledColor: AppColors.divider,
          ),
          IconButton(
            onPressed: _isLast
                ? null
                : () => _goToPage(widget.totalPages - 1),
            icon: const Icon(Icons.last_page),
            tooltip: 'Last page',
            color: AppColors.textPrimary,
            disabledColor: AppColors.divider,
          ),
        ],
      ),
    );
  }
}
