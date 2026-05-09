import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import '../../providers/manga_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/recommendation_providers.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/recommendation_section.dart';
import '../notifications/widgets/notification_card.dart';
import 'widgets/featured_carousel.dart';
import 'widgets/home_screen_skeleton.dart';
import 'widgets/manga_horizontal_list.dart';
import 'widgets/manga_section_header.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final featuredAsync = ref.watch(featuredMangaProvider);
    final latestAsync = ref.watch(latestMangaProvider);
    final popularAsync = ref.watch(popularMangaProvider);
    final completedAsync = ref.watch(completedMangaProvider);
    final recsAsync = ref.watch(recommendationsProvider);

    final isLoading = featuredAsync.isLoading ||
        latestAsync.isLoading ||
        popularAsync.isLoading ||
        completedAsync.isLoading;

    if (isLoading) {
      return const Scaffold(body: HomeScreenSkeleton());
    }

    if (featuredAsync.hasError) {
      return Scaffold(
        body: ErrorView(
          message: 'Không thể tải dữ liệu. Vui lòng thử lại.',
          onRetry: () {
            ref.invalidate(featuredMangaProvider);
            ref.invalidate(latestMangaProvider);
            ref.invalidate(popularMangaProvider);
            ref.invalidate(completedMangaProvider);
          },
        ),
      );
    }

    final featured = featuredAsync.valueOrNull ?? [];
    final latest = latestAsync.valueOrNull ?? [];
    final popular = popularAsync.valueOrNull ?? [];
    final completed = completedAsync.valueOrNull ?? [];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(featuredMangaProvider);
          ref.invalidate(latestMangaProvider);
          ref.invalidate(popularMangaProvider);
          ref.invalidate(completedMangaProvider);
        },
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              floating: true,
              snap: true,
              title: const Text(
                'MangaApp',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => context.go(RouteNames.search),
                ),
                Consumer(
                  builder: (_, ref, __) {
                    final unread = ref.watch(unreadCountProvider);
                    return IconButton(
                      icon: NotificationBadge(
                        count: unread,
                        child: const Icon(Icons.notifications_outlined),
                      ),
                      onPressed: () =>
                          context.push(RouteNames.notifications),
                    );
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
            ),
            if (featured.isNotEmpty)
              SliverToBoxAdapter(
                child: FeaturedCarousel(
                  items: featured,
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.id)),
                ),
              ),
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Mới Cập Nhật',
                items: latest,
                onSeeAll: () => context.push(RouteNames.search),
                onTapManga: (m) =>
                    context.push(RouteNames.mangaDetail(m.id)),
              ),
            ),
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Phổ Biến',
                items: popular,
                onSeeAll: () => context.push(RouteNames.search),
                onTapManga: (m) =>
                    context.push(RouteNames.mangaDetail(m.id)),
              ),
            ),
            SliverToBoxAdapter(
              child: _HomeSection(
                title: 'Hoàn Thành',
                items: completed,
                onSeeAll: () => context.push(RouteNames.search),
                onTapManga: (m) =>
                    context.push(RouteNames.mangaDetail(m.id)),
              ),
            ),
            recsAsync.maybeWhen(
              data: (recs) => SliverToBoxAdapter(
                child: RecommendationSection(
                  recommendations: recs,
                  onTapManga: (id) =>
                      context.push(RouteNames.mangaDetail(id)),
                ),
              ),
              orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
            ),
            const SliverToBoxAdapter(child: Gap(AppSpacing.xl)),
          ],
        ),
      ),
    );
  }
}

class _HomeSection extends StatelessWidget {
  const _HomeSection({
    required this.title,
    required this.items,
    this.onSeeAll,
    this.onTapManga,
  });

  final String title;
  final List<Manga> items;
  final VoidCallback? onSeeAll;
  final void Function(Manga manga)? onTapManga;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: MangaSectionHeader(title: title, onSeeAll: onSeeAll),
          ),
          const Gap(AppSpacing.md),
          MangaHorizontalList(items: items, onTapManga: onTapManga),
        ],
      ),
    );
  }
}
