import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class AIFlagBadge extends StatelessWidget {
  const AIFlagBadge({
    super.key,
    required this.confidence,
    this.compact = false,
  });

  final double confidence;
  final bool compact;

  Color get _color {
    if (confidence >= 0.8) return AppColors.error;
    if (confidence >= 0.5) return AppColors.warning;
    return AppColors.statusGreen;
  }

  String get _label {
    if (confidence >= 0.8) return 'AI: High Risk';
    if (confidence >= 0.5) return 'AI: Suspicious';
    return 'AI: Normal';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Tooltip(
        message: '$_label (${(confidence * 100).toStringAsFixed(0)}%)',
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: _color.withAlpha(25),
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(color: _color.withAlpha(80)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.smart_toy_outlined, size: 10, color: _color),
              const SizedBox(width: 2),
              Text(
                '${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 10,
                  color: _color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: _color.withAlpha(20),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: _color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Icon(Icons.smart_toy_outlined, color: _color, size: 20),
          const Gap(AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assessment',
                  style: TextStyle(
                    fontSize: 12,
                    color: _color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  _label,
                  style: TextStyle(fontSize: 12, color: _color),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${(confidence * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: _color,
                ),
              ),
              Text(
                'confidence',
                style: TextStyle(
                  fontSize: 10,
                  color: _color.withAlpha(180),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
