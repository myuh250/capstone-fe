import 'package:flutter/material.dart';

import '../../core/theme/app_spacing.dart';

const _genreColors = <String, Color>{
  'action': Color(0xFFE53935),
  'adventure': Color(0xFFFF8F00),
  'comedy': Color(0xFFFDD835),
  'drama': Color(0xFF8E24AA),
  'fantasy': Color(0xFF7C4DFF),
  'horror': Color(0xFF37474F),
  'mystery': Color(0xFF5C6BC0),
  'romance': Color(0xFFEC407A),
  'sci-fi': Color(0xFF00ACC1),
  'slice of life': Color(0xFF66BB6A),
  'sports': Color(0xFFFF7043),
  'supernatural': Color(0xFFAB47BC),
  'thriller': Color(0xFFD32F2F),
  'historical': Color(0xFF8D6E63),
  'school life': Color(0xFF29B6F6),
  'martial arts': Color(0xFFEF6C00),
  'psychological': Color(0xFF7E57C2),
  'isekai': Color(0xFF26A69A),
  'mecha': Color(0xFF78909C),
  'music': Color(0xFFAB47BC),
  'harem': Color(0xFFF06292),
  'ecchi': Color(0xFFFF80AB),
  'shounen': Color(0xFF42A5F5),
  'shoujo': Color(0xFFF48FB1),
  'seinen': Color(0xFF546E7A),
  'josei': Color(0xFFCE93D8),
};

Color _colorForGenre(String label) {
  final key = label.toLowerCase();
  if (_genreColors.containsKey(key)) return _genreColors[key]!;
  final hash = key.hashCode.abs();
  return HSLColor.fromAHSL(1.0, (hash % 360).toDouble(), 0.6, 0.55).toColor();
}

class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTap,
    this.compact = false,
  });

  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = _colorForGenre(label);
    final bg = backgroundColor ?? color.withAlpha(30);
    final border = backgroundColor != null ? null : color.withAlpha(130);
    final text = textColor ?? color;

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: border != null ? Border.all(color: border) : null,
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: text,
              fontWeight: FontWeight.w600,
            ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: chip,
      );
    }

    return chip;
  }
}
