import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/network/api_endpoints.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../models/manga.dart';
import '../../../shared/widgets/tag_chip.dart';

class FeaturedCarousel extends StatefulWidget {
  const FeaturedCarousel({
    super.key,
    required this.items,
    this.onTapManga,
  });

  final List<Manga> items;
  final void Function(Manga manga)? onTapManga;

  @override
  State<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends State<FeaturedCarousel> {
  static const int _virtualCount = 10000;
  late final PageController _pageController;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || widget.items.isEmpty) return;
      final nextPage = (_pageController.page?.round() ?? 0) + 1;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    final itemCount = widget.items.length;

    return SizedBox(
      height: 360,
      child: Stack(
        children: [
          ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(
              dragDevices: {
                PointerDeviceKind.touch,
                PointerDeviceKind.mouse,
              },
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: _virtualCount,
              onPageChanged: (index) =>
                  setState(() => _currentIndex = index % itemCount),
              itemBuilder: (context, index) {
                final realIndex = index % itemCount;
                return _CarouselItem(
                  manga: widget.items[realIndex],
                  onTap: widget.onTapManga != null
                      ? () => widget.onTapManga!(widget.items[realIndex])
                      : null,
                );
              },
            ),
          ),
          Positioned(
            bottom: AppSpacing.md,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(itemCount, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  width: index == _currentIndex ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == _currentIndex
                        ? AppColors.primary
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _CarouselItem extends StatelessWidget {
  const _CarouselItem({required this.manga, this.onTap});

  final Manga manga;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.network(
            manga.coverUrl.startsWith('http')
                ? manga.coverUrl
                : '${ApiEndpoints.baseUrl.replaceAll(RegExp(r'/api$'), '')}${manga.coverUrl}',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surface,
              child: const Icon(
                Icons.broken_image_outlined,
                size: 48,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.85),
                ],
                stops: const [0.4, 1.0],
              ),
            ),
          ),
          Positioned(
            left: AppSpacing.lg,
            right: AppSpacing.lg,
            bottom: AppSpacing.xxl,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  manga.title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          const Shadow(
                            blurRadius: 4,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(AppSpacing.xs),
                if (manga.tags.isNotEmpty)
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: manga.tags
                        .take(3)
                        .map((t) => TagChip(label: t, compact: true))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
