import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';

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

  void _showShareSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShareSheet(title: title, url: url),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        icon: Icon(Icons.share_outlined, color: color),
        tooltip: 'Chia sẻ',
        onPressed: () => _showShareSheet(context),
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
      onPressed: () => _showShareSheet(context),
      icon: const Icon(Icons.share_outlined, size: 18),
      label: const Text('Chia sẻ'),
    );
  }
}

class _ShareSheet extends StatelessWidget {
  const _ShareSheet({required this.title, required this.url});

  final String title;
  final String url;

  @override
  Widget build(BuildContext context) {
    final options = [
      _ShareOption(
        icon: Icons.link,
        label: 'Sao chép liên kết',
        color: AppColors.primary,
        onTap: () {
          Clipboard.setData(ClipboardData(text: url));
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Đã sao chép liên kết'),
              duration: Duration(seconds: 2),
            ),
          );
        },
      ),
      _ShareOption(
        icon: Icons.facebook,
        label: 'Facebook',
        color: const Color(0xFF1877F2),
        onTap: () => Navigator.of(context).pop(),
      ),
      _ShareOption(
        icon: Icons.telegram,
        label: 'Telegram',
        color: const Color(0xFF0088CC),
        onTap: () => Navigator.of(context).pop(),
      ),
      _ShareOption(
        icon: Icons.chat_outlined,
        label: 'Zalo',
        color: const Color(0xFF0068FF),
        onTap: () => Navigator.of(context).pop(),
      ),
      _ShareOption(
        icon: Icons.more_horiz,
        label: 'Khác',
        color: AppColors.textSecondary,
        onTap: () => Navigator.of(context).pop(),
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ),
              const Gap(AppSpacing.lg),
              Text(
                'Chia sẻ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Gap(AppSpacing.xs),
              Text(
                title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Gap(AppSpacing.xl),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: options
                    .map((o) => _ShareOptionButton(option: o))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareOption {
  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
}

class _ShareOptionButton extends StatelessWidget {
  const _ShareOptionButton({required this.option});

  final _ShareOption option;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: option.onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: option.color.withAlpha(25),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Icon(option.icon, color: option.color, size: 26),
            ),
            const Gap(AppSpacing.xs),
            Text(
              option.label,
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
