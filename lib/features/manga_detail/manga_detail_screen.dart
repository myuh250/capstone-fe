import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/chapter.dart';
import '../../models/manga.dart';
import '../../providers/comment_providers.dart';
import '../../providers/manga_providers.dart';
import '../../providers/recommendation_providers.dart';
import '../../shared/widgets/error_view.dart';
import '../../shared/widgets/recommendation_section.dart';
import 'widgets/chapter_list.dart';
import 'widgets/comment_section.dart';
import 'widgets/manga_description.dart';
import 'widgets/manga_header.dart';
import 'widgets/rating_dialog.dart';
import 'widgets/rating_display.dart';
import 'widgets/related_manga_section.dart';

class MangaDetailScreen extends ConsumerWidget {
  const MangaDetailScreen({super.key, required this.mangaSlug});

  final String mangaSlug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(mangaBySlugProvider(mangaSlug));

    return Scaffold(
      appBar: mangaAsync.whenOrNull(
        data: (manga) => AppBar(
          title: Text(
            manga.title,
            overflow: TextOverflow.ellipsis,
          ),
          leading: BackButton(
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                context.go(RouteNames.home);
              }
            },
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: mangaAsync.when(
            data: (manga) {
              final isFavorite = ref.watch(favoriteProvider(manga.id));
              final recsAsync = ref.watch(mangaRecommendationsProvider(manga.id));
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _SectionBorder(
                      child: MangaHeader(
                        manga: manga,
                        isFavorite: isFavorite,
                        onToggleFavorite: () =>
                            ref.read(favoriteProvider(manga.id).notifier).toggle(),
                        onReadNow: () {
                          final chapters = ref.read(chapterListProvider(manga.id)).chapters;
                          if (chapters.isNotEmpty) {
                            _navigateToReader(context, chapters.last, manga: manga);
                          }
                        },
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(
                    child: _SectionDivider(),
                  ),
                  if (manga.description != null && manga.description!.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _SectionBorder(
                        child: MangaDescription(description: manga.description!),
                      ),
                    ),
                  const SliverToBoxAdapter(child: _SectionDivider()),
                  SliverToBoxAdapter(
                    child: _SectionBorder(
                      child: ChapterList(
                        mangaId: manga.id,
                        onTapChapter: (chapter) =>
                            _navigateToReader(context, chapter, manga: manga),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _SectionDivider()),
                  SliverToBoxAdapter(
                    child: _SectionBorder(
                      child: _RatingSection(
                        mangaId: manga.id,
                        manga: manga,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _SectionDivider()),
                  SliverToBoxAdapter(
                    child: _SectionBorder(
                      child: CommentSection(mangaId: manga.id),
                    ),
                  ),
                  const SliverToBoxAdapter(child: _SectionDivider()),
                  SliverToBoxAdapter(
                    child: _SectionBorder(
                      child: RelatedMangaSection(
                        mangaId: manga.id,
                        onTapManga: (id) =>
                            context.pushReplacement(RouteNames.mangaDetail(id)),
                      ),
                    ),
                  ),
                  recsAsync.maybeWhen(
                    data: (recs) => SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const _SectionDivider(),
                          _SectionBorder(
                            child: RecommendationSection(
                              title: 'You May Also Like',
                              recommendations: recs,
                              onTapManga: (id) =>
                                  context.pushReplacement(RouteNames.mangaDetail(id)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    orElse: () => const SliverToBoxAdapter(child: SizedBox.shrink()),
                  ),
                ],
              );
            },
            loading: () => const _MangaDetailSkeleton(),
            error: (e, _) => ErrorView(
              message: e is Exception ? e.toString() : 'Unable to load manga.',
              onRetry: () => ref.invalidate(mangaBySlugProvider(mangaSlug)),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToReader(BuildContext context, Chapter chapter, {required Manga manga}) {
    final slug = manga.slug ?? mangaSlug;
    context.push(RouteNames.reader(slug, chapter.number));
  }
}


class _RatingSection extends ConsumerWidget {
  const _RatingSection({
    required this.mangaId,
    required this.manga,
  });

  final String mangaId;
  final dynamic manga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userRatingAsync = ref.watch(userRatingProvider(mangaId));
    final userRating = userRatingAsync.valueOrNull;
    final statsAsync = ref.watch(mangaRatingStatsProvider(mangaId));
    final stats = statsAsync.valueOrNull;

    final averageRating = stats?.averageScore ?? manga.averageRating;
    final ratingCount = stats?.ratingCount ?? 0;

    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rating',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.md),
          RatingDisplay(
            averageRating: averageRating,
            ratingCount: ratingCount,
            userRating: userRating,
            onRate: () => showRatingDialog(
              context,
              ref: ref,
              mangaId: mangaId,
              mangaTitle: manga.title,
            ),
          ),
          if (userRating != null) ...[
            const SizedBox(height: AppSpacing.sm),
            UserRatingBadge(rating: userRating),
          ],
        ],
      ),
    );
  }
}

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: AppSpacing.md);
  }
}

class _SectionBorder extends StatelessWidget {
  const _SectionBorder({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.primary.withAlpha(180),
          width: 1.2,
        ),
      ),
      child: child,
    );
  }
}

class _MangaDetailSkeleton extends StatelessWidget {
  const _MangaDetailSkeleton();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 56,
              color: AppColors.surface,
            ),
            Container(
              color: AppColors.surface,
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 110,
                    height: 165,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceAlt,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(
                        5,
                        (i) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.sm,
                          ),
                          child: Container(
                            height: 16,
                            width: i == 0 ? double.infinity : 120.0 - i * 10,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
