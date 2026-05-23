import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../providers/manga_providers.dart';
import '../../../shared/widgets/cover_image.dart';

class RelatedMangaSection extends ConsumerWidget {
  const RelatedMangaSection({
    super.key,
    required this.mangaId,
    required this.onTapManga,
  });

  final String mangaId;
  final void Function(String mangaId) onTapManga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedMangaProvider(mangaId));

    return relatedAsync.when(
      data: (related) {
        if (related.isEmpty) return const SizedBox.shrink();
        return _RelatedContent(
          items: related,
          onTapManga: onTapManga,
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _RelatedContent extends StatefulWidget {
  const _RelatedContent({
    required this.items,
    required this.onTapManga,
  });

  final List<Manga> items;
  final void Function(String mangaId) onTapManga;

  @override
  State<_RelatedContent> createState() => _RelatedContentState();
}

class _RelatedContentState extends State<_RelatedContent> {
  int _currentPage = 0;
  static const _itemsPerPage = 6;

  int get _pageCount => (widget.items.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.md,
            ),
            child: Text(
              'Related Manga',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          SizedBox(
            height: 200,
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                },
              ),
              child: PageView.builder(
                itemCount: _pageCount,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, pageIndex) {
                  final start = pageIndex * _itemsPerPage;
                  final end =
                      (start + _itemsPerPage).clamp(0, widget.items.length);
                  final pageItems = widget.items.sublist(start, end);

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < pageItems.length; i++) ...[
                          if (i > 0) const Gap(AppSpacing.md),
                          Expanded(
                            child: _RelatedCard(
                              manga: pageItems[i],
                              onTap: () =>
                                  widget.onTapManga(pageItems[i].id),
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
          if (_pageCount > 1) ...[
            const Gap(AppSpacing.sm),
            _PageDots(current: _currentPage, total: _pageCount),
          ],
          const Gap(AppSpacing.xl),
        ],
      ),
    );
  }
}

class _RelatedCard extends StatelessWidget {
  const _RelatedCard({required this.manga, required this.onTap});

  final Manga manga;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              child: CoverImage(imageUrl: manga.coverUrl),
            ),
          ),
          const Gap(AppSpacing.xs),
          Text(
            manga.title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  const _PageDots({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final isActive = i == current;
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
    );
  }
}
