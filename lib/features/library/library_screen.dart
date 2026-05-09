import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../providers/library_providers.dart';
import '../../providers/manga_providers.dart';
import '../../shared/widgets/empty_state.dart';
import '../../shared/widgets/error_view.dart';
import '../library/widgets/favorites_manga_card.dart';
import '../library/widgets/history_list_tile.dart';
import '../library/widgets/continue_reading_card.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thư viện'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          tabs: const [
            Tab(text: 'Yêu thích'),
            Tab(text: 'Lịch sử đọc'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _FavoritesTab(),
          _HistoryTab(),
        ],
      ),
    );
  }
}

class _FavoritesTab extends ConsumerWidget {
  const _FavoritesTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favsAsync = ref.watch(favoritesProvider);

    return favsAsync.when(
      loading: () => const _ListSkeleton(),
      error: (e, _) => ErrorView(
        message: 'Không thể tải danh sách yêu thích',
        onRetry: () => ref.invalidate(favoritesProvider),
      ),
      data: (favs) {
        if (favs.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_border,
              message: 'Nhấn vào biểu tượng tim trên trang manga để thêm vào yêu thích',
            );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: favs.length,
          separatorBuilder: (_, __) => const Gap(AppSpacing.sm),
          itemBuilder: (_, i) {
            final manga = favs[i];
            return FavoritesMangaCard(
              manga: manga,
              onTap: () => context.push(RouteNames.mangaDetail(manga.id)),
              onRemove: () =>
                  ref.read(favoriteProvider(manga.id).notifier).toggle(),
            );
          },
        );
      },
    );
  }
}

class _HistoryTab extends ConsumerWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(readingHistoryProvider);
    final continueAsync = ref.watch(continueReadingProvider);

    return historyAsync.when(
      loading: () => const _ListSkeleton(),
      error: (e, _) => ErrorView(
        message: 'Không thể tải lịch sử đọc',
        onRetry: () => ref.invalidate(readingHistoryProvider),
      ),
      data: (history) {
        if (history.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              message: 'Bắt đầu đọc manga để lịch sử hiện ở đây',
            );
        }
        return ListView(
          children: [
            continueAsync.maybeWhen(
              data: (recent) => recent != null
                  ? ContinueReadingCard(
                      history: recent,
                      onTap: () => context.push(
                        RouteNames.reader(
                          recent.mangaId,
                          recent.lastChapterId,
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
              orElse: () => const SizedBox.shrink(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TẤT CẢ (${history.length})',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                  ),
                  TextButton(
                    onPressed: () =>
                        context.push(RouteNames.readingHistory),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.take(5).length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                indent: AppSpacing.lg + 56 + AppSpacing.md,
                color: AppColors.divider,
              ),
              itemBuilder: (_, i) {
                final h = history[i];
                return HistoryListTile(
                  history: h,
                  onTap: () => context.push(RouteNames.mangaDetail(h.mangaId)),
                  onContinue: () => context.push(
                    RouteNames.reader(h.mangaId, h.lastChapterId),
                  ),
                  onRemove: () => ref
                      .read(readingHistoryProvider.notifier)
                      .removeEntry(h.mangaId),
                );
              },
            ),
            const Gap(AppSpacing.xxxl),
          ],
        );
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: 5,
        separatorBuilder: (_, __) =>
            const SizedBox(height: AppSpacing.sm),
        itemBuilder: (_, __) => Container(
          height: 92,
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      ),
    );
  }
}
