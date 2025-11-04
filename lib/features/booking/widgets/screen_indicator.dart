import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class ScreenIndicator extends StatelessWidget {
  const ScreenIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Screen shape with modern gradient
        Container(
          height: 60,
          child: CustomPaint(
            size: Size(MediaQuery.of(context).size.width * 0.9, 60),
            painter: ScreenPainter(),
          ),
        ),

        SizedBox(height: AppSpacing.md),

        // Screen label with icon
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.monitor,
              size: 16,
              color: AppColors.textTertiary,
            ),
            SizedBox(width: AppSpacing.xs),
            Text(
              'PANTALLA',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 3,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.monitor,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ],
    );
  }
}

class ScreenPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base screen shape with gradient
    final basePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.1),
          AppColors.surfaceVariant,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    final path = Path();

    // Create curved IMAX-style screen shape
    final curveHeight = 15.0;
    final width = size.width;
    final screenHeight = size.height;

    path.moveTo(width * 0.05, curveHeight);
    path.quadraticBezierTo(
      width / 2,
      0,
      width * 0.95,
      curveHeight,
    );
    path.lineTo(width * 0.90, screenHeight);
    path.lineTo(width * 0.10, screenHeight);
    path.close();

    canvas.drawPath(path, basePaint);

    // Add glow effect at the top
    final glowPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          AppColors.primary.withOpacity(0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height / 2))
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, glowPaint);

    // Add border outline
    final borderPaint = Paint()
      ..color = AppColors.primary.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
