import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class ModerationActionBar extends StatelessWidget {
  const ModerationActionBar({
    super.key,
    required this.onResolve,
    required this.onDismiss,
    this.onWarn,
    this.onBan,
    this.isLoading = false,
  });

  final VoidCallback onResolve;
  final VoidCallback onDismiss;
  final VoidCallback? onWarn;
  final VoidCallback? onBan;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Resolve',
                  icon: Icons.check_circle_outline,
                  color: AppColors.statusGreen,
                  onTap: onResolve,
                  isLoading: isLoading,
                ),
              ),
              const Gap(AppSpacing.sm),
              Expanded(
                child: _ActionButton(
                  label: 'Dismiss',
                  icon: Icons.cancel_outlined,
                  color: AppColors.textSecondary,
                  onTap: onDismiss,
                  isLoading: isLoading,
                ),
              ),
            ],
          ),
          if (onWarn != null || onBan != null) ...[
            const Gap(AppSpacing.sm),
            Row(
              children: [
                if (onWarn != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Warn',
                      icon: Icons.warning_amber_outlined,
                      color: AppColors.warning,
                      onTap: onWarn!,
                      isLoading: isLoading,
                      outlined: true,
                    ),
                  ),
                if (onWarn != null && onBan != null) const Gap(AppSpacing.sm),
                if (onBan != null)
                  Expanded(
                    child: _ActionButton(
                      label: 'Ban Account',
                      icon: Icons.block_outlined,
                      color: AppColors.error,
                      onTap: onBan!,
                      isLoading: isLoading,
                      outlined: true,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton.icon(
        onPressed: isLoading ? null : onTap,
        icon: Icon(icon, size: 16, color: color),
        label: Text(
          label,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: color.withAlpha(100)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          minimumSize: const Size.fromHeight(44),
        ),
      );
    }
    return FilledButton.icon(
      onPressed: isLoading ? null : onTap,
      icon: Icon(icon, size: 16),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        minimumSize: const Size.fromHeight(44),
      ),
    );
  }
}
