import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class CinemaCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final bool elevated;
  final Color? color;
  final double? borderRadius;
  final Border? border;

  const CinemaCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.elevated = false,
    this.color,
    this.borderRadius,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMD,
      ),
      elevation: elevated ? 4 : 0,
      shadowColor: Colors.black.withOpacity(0.3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(
          borderRadius ?? AppSpacing.radiusMD,
        ),
        child: Container(
          padding: padding ?? AppSpacing.cardPadding,
          decoration: border != null
              ? BoxDecoration(
                  border: border,
                  borderRadius: BorderRadius.circular(
                    borderRadius ?? AppSpacing.radiusMD,
                  ),
                )
              : null,
          child: child,
        ),
      ),
    );
  }
}
