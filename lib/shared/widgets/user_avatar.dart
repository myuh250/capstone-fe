import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../core/network/api_endpoints.dart';
import '../../core/theme/app_colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    this.imageUrl,
    this.name,
    this.size = 40,
    this.backgroundColor,
    this.isPremium = false,
  });

  final String? imageUrl;
  final String? name;
  final double size;
  final Color? backgroundColor;
  final bool isPremium;

  static const _goldGradient = LinearGradient(
    colors: [Color(0xFFFFD700), Color(0xFFFFA500), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String? get _resolvedUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return null;
    if (imageUrl!.startsWith('http')) return imageUrl;
    final base = ApiEndpoints.baseUrl.replaceAll(RegExp(r'/api$'), '');
    return '$base$imageUrl';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolvedUrl;
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? AppColors.surfaceAlt,
      backgroundImage: url != null ? CachedNetworkImageProvider(url) : null,
      child: url == null
          ? Text(
              _getInitials(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
            )
          : null,
    );

    if (!isPremium) return avatar;

    final borderWidth = (size * 0.06).clamp(2.0, 4.0);
    return Container(
      padding: EdgeInsets.all(borderWidth),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: _goldGradient,
      ),
      child: avatar,
    );
  }

  String _getInitials() {
    if (name == null || name!.isEmpty) return '?';

    final parts = name!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else {
      return name![0].toUpperCase();
    }
  }
}
