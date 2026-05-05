import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

enum PasswordStrength { empty, weak, fair, strong, veryStrong }

extension PasswordStrengthExtension on PasswordStrength {
  String get label => switch (this) {
        PasswordStrength.empty => '',
        PasswordStrength.weak => 'Yếu',
        PasswordStrength.fair => 'Trung bình',
        PasswordStrength.strong => 'Mạnh',
        PasswordStrength.veryStrong => 'Rất mạnh',
      };

  Color get color => switch (this) {
        PasswordStrength.empty => Colors.transparent,
        PasswordStrength.weak => AppColors.error,
        PasswordStrength.fair => AppColors.warning,
        PasswordStrength.strong => AppColors.statusGreen,
        PasswordStrength.veryStrong => AppColors.statusBlue,
      };

  int get filledBars => switch (this) {
        PasswordStrength.empty => 0,
        PasswordStrength.weak => 1,
        PasswordStrength.fair => 2,
        PasswordStrength.strong => 3,
        PasswordStrength.veryStrong => 4,
      };
}

PasswordStrength evaluatePasswordStrength(String password) {
  if (password.isEmpty) return PasswordStrength.empty;
  if (password.length < 6) return PasswordStrength.weak;

  int score = 0;
  if (password.length >= 8) score++;
  if (RegExp(r'[A-Z]').hasMatch(password)) score++;
  if (RegExp(r'[0-9]').hasMatch(password)) score++;
  if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) score++;

  return switch (score) {
    0 || 1 => PasswordStrength.weak,
    2 => PasswordStrength.fair,
    3 => PasswordStrength.strong,
    _ => PasswordStrength.veryStrong,
  };
}

class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });

  final String password;

  @override
  Widget build(BuildContext context) {
    final strength = evaluatePasswordStrength(password);
    if (strength == PasswordStrength.empty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: List.generate(4, (index) {
            final isFilled = index < strength.filledBars;
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(right: index < 3 ? AppSpacing.xs : 0),
                decoration: BoxDecoration(
                  color: isFilled ? strength.color : AppColors.divider,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          strength.label,
          style: TextStyle(
            fontSize: 12,
            color: strength.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
