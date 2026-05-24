import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/constants.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  String get _resolvedUrl {
    if (imageUrl.startsWith('http')) return imageUrl;
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/api$'), '');
    return '$base$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final image = ClipRRect(
      borderRadius: borderRadius ??
          BorderRadius.circular(AppSpacing.coverRadius),
      child: kIsWeb
          ? Image.network(
              _resolvedUrl,
              width: width,
              height: height,
              fit: fit,
              loadingBuilder: (context, child, progress) =>
                  progress == null ? child : _CoverPlaceholder(),
              errorBuilder: (context, error, stack) => _CoverError(),
            )
          : CachedNetworkImage(
              imageUrl: _resolvedUrl,
              width: width,
              height: height,
              fit: fit,
              memCacheWidth: AppConstants.imageCacheWidth,
              placeholder: (context, url) => _CoverPlaceholder(),
              errorWidget: (context, url, error) => _CoverError(),
            ),
    );

    if (width != null && height != null) {
      return SizedBox(width: width, height: height, child: image);
    }

    return AspectRatio(
      aspectRatio: AppConstants.coverAspectRatio,
      child: image,
    );
  }
}

class _CoverPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceAlt,
      highlightColor: AppColors.surface,
      child: Container(
        color: AppColors.surfaceAlt,
      ),
    );
  }
}

class _CoverError extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surfaceAlt,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 48,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
