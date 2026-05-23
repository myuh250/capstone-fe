import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.title,
    required this.url,
    this.compact = false,
    this.color,
  });

  final String title;
  final String url;
  final bool compact;
  final Color? color;

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Link copied'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        icon: Icon(Icons.copy_outlined, color: color),
        tooltip: 'Copy link',
        onPressed: () => _copyLink(context),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: color ?? AppColors.textPrimary,
        side: BorderSide(color: color ?? AppColors.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      onPressed: () => _copyLink(context),
      icon: const Icon(Icons.copy_outlined, size: 18),
      label: const Text('Copy link'),
    );
  }
}

