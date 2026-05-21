import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import '../../providers/manga_providers.dart';
import '../../providers/notification_providers.dart';
import '../../providers/recommendation_providers.dart';
import '../../shared/widgets/recommendation_section.dart';
import '../notifications/widgets/notification_card.dart';
import 'widgets/featured_carousel.dart';
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
            // Each section renders independently — a slow section won't block others
            SliverToBoxAdapter(
              child: featuredAsync.when(
                data: (featured) => featured.isEmpty
                    ? const SizedBox.shrink()
                    : FeaturedCarousel(
                        items: featured,
                        onTapManga: (m) =>
                            context.push(RouteNames.mangaDetail(m.id)),
                      ),
                loading: () => const _SectionSkeleton(height: 220),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: latestAsync.when(
                data: (latest) => _HomeSection(
                  title: 'Mới Cập Nhật',
                  items: latest,
                  onSeeAll: () => context.push(RouteNames.search),
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.id)),
                ),
                loading: () => const _SectionSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: popularAsync.when(
                data: (popular) => _HomeSection(
                  title: 'Phổ Biến',
                  items: popular,
                  onSeeAll: () => context.push(RouteNames.search),
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.id)),
                ),
                loading: () => const _SectionSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: completedAsync.when(
                data: (completed) => _HomeSection(
                  title: 'Hoàn Thành',
                  items: completed,
                  onSeeAll: () => context.push(RouteNames.search),
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.id)),
                ),
                loading: () => const _SectionSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
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

// Lightweight inline skeleton shown per-section while loading,
// instead of blanking the whole screen.
class _SectionSkeleton extends StatelessWidget {
  const _SectionSkeleton({this.height = 160});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Container(
              height: 18,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.surfaceAlt,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
          ),
          const Gap(AppSpacing.md),
          SizedBox(
            height: height,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Container(
                  width: 110,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

