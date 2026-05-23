import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/manga.dart';
import '../../providers/manga_providers.dart';
import '../../providers/recommendation_providers.dart';
import '../../shared/widgets/manga_card.dart';
import 'widgets/featured_carousel.dart';
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
            ),
            // Each section renders independently — a slow section won't block others
            SliverToBoxAdapter(
              child: featuredAsync.when(
                data: (featured) => featured.isEmpty
                    ? const SizedBox.shrink()
                    : FeaturedCarousel(
                        items: featured,
                        onTapManga: (m) =>
                            context.push(RouteNames.mangaDetail(m.slug ?? m.id)),
                      ),
                loading: () => const _SectionSkeleton(height: 220),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: latestAsync.when(
                data: (latest) => _HomeSection(
                  title: 'Latest Updates',
                  items: latest,
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.slug ?? m.id)),
                ),
                loading: () => const _SectionSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: popularAsync.when(
                data: (popular) => _HomeSection(
                  title: 'Popular',
                  items: popular,
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.slug ?? m.id)),
                ),
                loading: () => const _SectionSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            SliverToBoxAdapter(
              child: completedAsync.when(
                data: (completed) => _HomeSection(
                  title: 'Completed',
                  items: completed,
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.slug ?? m.id)),
                ),
                loading: () => const _SectionSkeleton(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),
            recsAsync.maybeWhen(
              data: (recs) => SliverToBoxAdapter(
                child: _HomeSection(
                  title: 'Recommended for You',
                  items: recs.map((r) => r.manga).toList(),
                  onTapManga: (m) =>
                      context.push(RouteNames.mangaDetail(m.slug ?? m.id)),
                  showRating: false,
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

class _HomeSection extends StatefulWidget {
  const _HomeSection({
    required this.title,
    required this.items,
    this.onTapManga,
    this.showRating = true,
  });

  final String title;
  final List<Manga> items;
  final void Function(Manga manga)? onTapManga;
  final bool showRating;

  @override
  State<_HomeSection> createState() => _HomeSectionState();
}

class _HomeSectionState extends State<_HomeSection> {
  int _currentPage = 0;
  static const double _cardWidth = 130;
  static const double _cardSpacing = AppSpacing.md;
  static const double _horizontalPadding = AppSpacing.lg;

  int _itemsPerPage(double availableWidth) {
    final usable = availableWidth - _horizontalPadding * 2;
    return ((usable + _cardSpacing) / (_cardWidth + _cardSpacing)).floor().clamp(1, widget.items.length);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final perPage = _itemsPerPage(constraints.maxWidth);
        final pageCount = (widget.items.length / perPage).ceil();

        return Padding(
          padding: const EdgeInsets.only(top: AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: MangaSectionHeader(title: widget.title),
              ),
              const Gap(AppSpacing.md),
              SizedBox(
                height: 260,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(
                    dragDevices: {
                      PointerDeviceKind.touch,
                      PointerDeviceKind.mouse,
                    },
                  ),
                  child: PageView.builder(
                    itemCount: pageCount,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemBuilder: (_, pageIndex) {
                      final start = pageIndex * perPage;
                      final end = (start + perPage)
                          .clamp(0, widget.items.length);
                      final pageItems = widget.items.sublist(start, end);

                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: _horizontalPadding),
                        child: Row(
                          children: [
                            for (int i = 0; i < pageItems.length; i++) ...[
                              if (i > 0)
                                const SizedBox(width: _cardSpacing),
                              Expanded(
                                child: MangaCard(
                                  manga: pageItems[i],
                                  onTap: widget.onTapManga != null
                                      ? () => widget.onTapManga!(pageItems[i])
                                      : null,
                                  showRating: widget.showRating,
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
              if (pageCount > 1) ...[
                const Gap(AppSpacing.sm),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(pageCount, (i) {
                    final isActive = i == _currentPage;
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
                ),
              ],
            ],
          ),
        );
      },
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

