import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

enum ReaderTheme { dark, light, sepia }

extension ReaderThemeExtension on ReaderTheme {
  String get label => switch (this) {
        ReaderTheme.dark => 'Tối',
        ReaderTheme.light => 'Sáng',
        ReaderTheme.sepia => 'Sepia',
      };

  Color get backgroundColor => switch (this) {
        ReaderTheme.dark => Colors.black,
        ReaderTheme.light => Colors.white,
        ReaderTheme.sepia => const Color(0xFFF4ECD8),
      };

  Color get textColor => switch (this) {
        ReaderTheme.dark => Colors.white,
        ReaderTheme.light => Colors.black,
        ReaderTheme.sepia => const Color(0xFF5B4636),
      };
}

class ReaderSettingsPanel extends StatefulWidget {
  const ReaderSettingsPanel({
    super.key,
    required this.isVerticalMode,
    required this.brightness,
    required this.readerTheme,
    required this.autoNextChapter,
    required this.onToggleReadingMode,
    required this.onBrightnessChanged,
    required this.onThemeChanged,
    required this.onAutoNextChanged,
  });

  final bool isVerticalMode;
  final double brightness;
  final ReaderTheme readerTheme;
  final bool autoNextChapter;
  final VoidCallback onToggleReadingMode;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<ReaderTheme> onThemeChanged;
  final ValueChanged<bool> onAutoNextChanged;

  @override
  State<ReaderSettingsPanel> createState() => _ReaderSettingsPanelState();
}

class _ReaderSettingsPanelState extends State<ReaderSettingsPanel> {
  late double _brightness;

  @override
  void initState() {
    super.initState();
    _brightness = widget.brightness;
  }

  @override
  Widget build(BuildContext context) {
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
            crossAxisAlignment: CrossAxisAlignment.start,
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
                'Cài đặt đọc',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Gap(AppSpacing.xl),

              // Reading mode toggle
              _SectionLabel('Chế độ đọc'),
              const Gap(AppSpacing.sm),
              _ReadingModeToggle(
                isVertical: widget.isVerticalMode,
                onToggle: widget.onToggleReadingMode,
              ),
              const Gap(AppSpacing.xl),

              // Background theme
              _SectionLabel('Nền đọc'),
              const Gap(AppSpacing.sm),
              _ReaderThemeSelector(
                current: widget.readerTheme,
                onChanged: widget.onThemeChanged,
              ),
              const Gap(AppSpacing.xl),

              // Brightness (mobile only)
              _SectionLabel('Độ sáng'),
              const Gap(AppSpacing.xs),
              Row(
                children: [
                  const Icon(
                    Icons.brightness_low,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  Expanded(
                    child: Slider(
                      value: _brightness,
                      min: 0.1,
                      max: 1.0,
                      activeColor: AppColors.primary,
                      inactiveColor: AppColors.divider,
                      onChanged: (v) {
                        setState(() => _brightness = v);
                        widget.onBrightnessChanged(v);
                      },
                    ),
                  ),
                  const Icon(
                    Icons.brightness_high,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
              const Gap(AppSpacing.xl),

              // Auto-next chapter
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: SwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  title: const Text(
                    'Tự động sang chương tiếp',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  subtitle: const Text(
                    'Tự động chuyển chương khi đọc đến trang cuối',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  value: widget.autoNextChapter,
                  onChanged: widget.onAutoNextChanged,
                  activeThumbColor: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.4,
          ),
    );
  }
}

class _ReadingModeToggle extends StatelessWidget {
  const _ReadingModeToggle({
    required this.isVertical,
    required this.onToggle,
  });

  final bool isVertical;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeButton(
            icon: Icons.swap_vert_rounded,
            label: 'Cuộn dọc',
            selected: isVertical,
            onTap: !isVertical ? onToggle : null,
          ),
        ),
        const Gap(AppSpacing.sm),
        Expanded(
          child: _ModeButton(
            icon: Icons.swap_horiz_rounded,
            label: 'Lật trang',
            selected: !isVertical,
            onTap: isVertical ? onToggle : null,
          ),
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withAlpha(30)
              : AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.divider,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              size: 24,
            ),
            const Gap(4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? AppColors.primary : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReaderThemeSelector extends StatelessWidget {
  const _ReaderThemeSelector({
    required this.current,
    required this.onChanged,
  });

  final ReaderTheme current;
  final ValueChanged<ReaderTheme> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ReaderTheme.values.map((theme) {
        final isSelected = current == theme;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: theme != ReaderTheme.sepia ? AppSpacing.sm : 0,
            ),
            child: GestureDetector(
              onTap: () => onChanged(theme),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 52,
                decoration: BoxDecoration(
                  color: theme.backgroundColor,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.divider,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    theme.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.normal,
                      color: theme.textColor,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
