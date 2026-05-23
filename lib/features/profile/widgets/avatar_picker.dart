import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/user_avatar.dart';

class AvatarPicker extends StatelessWidget {
  const AvatarPicker({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.onPickImage,
    this.size = 88,
  });

  final String? imageUrl;
  final String name;
  final VoidCallback onPickImage;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPickImage,
      child: Stack(
        children: [
          UserAvatar(imageUrl: imageUrl, name: name, size: size),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 2),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AvatarPickerBottomSheet extends StatelessWidget {
  const AvatarPickerBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Text(
              'Change Avatar',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take Photo'),
            onTap: () => Navigator.of(context).pop('camera'),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from Gallery'),
            onTap: () => Navigator.of(context).pop('gallery'),
          ),
          ListTile(
            leading: Icon(Icons.delete_outline, color: AppColors.error),
            title: Text(
              'Remove Avatar',
              style: TextStyle(color: AppColors.error),
            ),
            onTap: () => Navigator.of(context).pop('remove'),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
