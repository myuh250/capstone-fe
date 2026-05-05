import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/chapter_page.dart';

class PageImage extends StatelessWidget {
  const PageImage({
    super.key,
    required this.page,
  });

  final ChapterPage page;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: page.imageUrl,
      fit: BoxFit.fitWidth,
      width: double.infinity,
      memCacheWidth: 900,
      maxWidthDiskCache: 1200,
      placeholder: (_, __) => _PageLoadingPlaceholder(page: page),
      errorWidget: (_, __, ___) => _PageErrorWidget(pageNumber: page.pageNumber),
    );
  }
}

class _PageLoadingPlaceholder extends StatelessWidget {
  const _PageLoadingPlaceholder({required this.page});

  final ChapterPage page;

  @override
  Widget build(BuildContext context) {
    final aspectRatio = (page.width != null && page.height != null)
        ? page.width! / page.height!
        : 2 / 3;
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Shimmer.fromColors(
        baseColor: AppColors.surfaceAlt,
        highlightColor: AppColors.surface,
        child: Container(color: AppColors.surfaceAlt),
      ),
    );
  }
}

class _PageErrorWidget extends StatelessWidget {
  const _PageErrorWidget({required this.pageNumber});

  final int pageNumber;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2 / 3,
      child: Container(
        color: AppColors.surface,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              'Trang $pageNumber không tải được',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
