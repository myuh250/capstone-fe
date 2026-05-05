import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/router/route_names.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/chapter.dart';
import '../../providers/manga_providers.dart';
import '../../shared/widgets/error_view.dart';
import 'widgets/chapter_list.dart';
import 'widgets/manga_description.dart';
import 'widgets/manga_header.dart';
import 'widgets/related_manga_section.dart';

class MangaDetailScreen extends ConsumerWidget {
  const MangaDetailScreen({super.key, required this.mangaId});

  final String mangaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mangaAsync = ref.watch(mangaDetailProvider(mangaId));
    final isFavorite = ref.watch(favoriteProvider(mangaId));

    return Scaffold(
      body: mangaAsync.when(
        data: (manga) => CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              floating: false,
              pinned: true,
              title: Text(
                manga.title,
                overflow: TextOverflow.ellipsis,
              ),
              leading: const BackButton(),
            ),
            SliverToBoxAdapter(
              child: MangaHeader(
                manga: manga,
                isFavorite: isFavorite,
                onToggleFavorite: () =>
                    ref.read(favoriteProvider(mangaId).notifier).toggle(),
              ),
            ),
            const SliverToBoxAdapter(
              child: _SectionDivider(),
            ),
            if (manga.description != null && manga.description!.isNotEmpty)
              SliverToBoxAdapter(
                child: MangaDescription(description: manga.description!),
              ),
            const SliverToBoxAdapter(child: _SectionDivider()),
            SliverToBoxAdapter(
              child: ChapterList(
                mangaId: mangaId,
                onTapChapter: (chapter) =>
                    _navigateToReader(context, chapter),
              ),
            ),
            const SliverToBoxAdapter(child: _SectionDivider()),
            SliverToBoxAdapter(
              child: RelatedMangaSection(
                mangaId: mangaId,
                onTapManga: (id) =>
                    context.pushReplacement(RouteNames.mangaDetail(id)),
              ),
            ),
          ],
        ),
        loading: () => const _MangaDetailSkeleton(),
        error: (e, _) => ErrorView(
          message: e is Exception ? e.toString() : 'Không thể tải manga.',
          onRetry: () => ref.invalidate(mangaDetailProvider(mangaId)),
        ),
      ),
    );
  }

  void _navigateToReader(BuildContext context, Chapter chapter) {
    context.push(RouteNames.reader(mangaId, chapter.id));
  }
}


class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppSpacing.sm,
      color: AppColors.background,
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

