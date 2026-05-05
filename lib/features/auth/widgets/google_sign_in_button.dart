import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        side: const BorderSide(color: AppColors.divider),
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.textSecondary,
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _GoogleLogo(),
                const SizedBox(width: AppSpacing.md),
                const Text(
                  'Đăng nhập bằng Google',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
    );
  }
}

class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Red arc (top-right)
    _drawArc(
      canvas,
      center,
      radius,
      -0.1,
      1.65,
      const Color(0xFFEA4335),
    );
    // Yellow arc (bottom-right)
    _drawArc(
      canvas,
      center,
      radius,
      1.55,
      1.1,
      const Color(0xFFFBBC05),
    );
    // Green arc (bottom-left)
    _drawArc(
      canvas,
      center,
      radius,
      2.65,
      1.15,
      const Color(0xFF34A853),
    );
    // Blue arc (top-left)
    _drawArc(
      canvas,
      center,
      radius,
      3.8,
      1.2,
      const Color(0xFF4285F4),
    );

    // White center hole
    canvas.drawCircle(
      center,
      radius * 0.55,
      Paint()..color = AppColors.surface,
    );

    // Blue horizontal bar (right side of G)
    final barPaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..strokeWidth = size.height * 0.22
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(center.dx, center.dy),
      Offset(center.dx + radius * 0.98, center.dy),
      barPaint,
    );
  }

  void _drawArc(
    Canvas canvas,
    Offset center,
    double radius,
    double startAngle,
    double sweepAngle,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.45
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.77),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
