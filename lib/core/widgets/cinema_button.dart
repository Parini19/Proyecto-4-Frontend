import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

enum ButtonVariant {
  primary, // Filled button with primary color
  secondary, // Filled button with secondary color
  outline, // Outlined button
  text, // Text-only button
  ghost, // Subtle button
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CinemaButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final IconData? suffixIcon;
  final Color? customColor;

  const CinemaButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.suffixIcon,
    this.customColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = _buildContent();

    switch (variant) {
      case ButtonVariant.primary:
        return _buildElevatedButton(content, AppColors.primary);
      case ButtonVariant.secondary:
        return _buildElevatedButton(content, AppColors.success);
      case ButtonVariant.outline:
        return _buildOutlinedButton(content);
      case ButtonVariant.text:
        return _buildTextButton(content);
      case ButtonVariant.ghost:
        return _buildGhostButton(content);
    }
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: _getIconSize(),
        width: _getIconSize(),
        child: const CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final List<Widget> children = [];

    if (icon != null) {
      children.add(Icon(icon, size: _getIconSize()));
      children.add(SizedBox(width: AppSpacing.gapSM));
    }

    children.add(
      Text(
        text,
        style: _getTextStyle(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (suffixIcon != null) {
      children.add(SizedBox(width: AppSpacing.gapSM));
      children.add(Icon(suffixIcon, size: _getIconSize()));
    }

    return Row(
      mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );
  }

  Widget _buildElevatedButton(Widget content, Color color) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: customColor ?? color,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.surfaceVariant,
          disabledForegroundColor: AppColors.textDisabled,
          elevation: 0,
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
        ),
        child: content,
      ),
    );
  }

  Widget _buildOutlinedButton(Widget content) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: customColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          side: BorderSide(
            color: customColor ?? AppColors.primary,
            width: 1.5,
          ),
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
        ),
        child: content,
      ),
    );
  }

  Widget _buildTextButton(Widget content) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: customColor ?? AppColors.primary,
          disabledForegroundColor: AppColors.textDisabled,
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
        ),
        child: content,
      ),
    );
  }

  Widget _buildGhostButton(Widget content) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      child: TextButton(
        onPressed: isLoading ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          disabledForegroundColor: AppColors.textDisabled,
          backgroundColor: Colors.transparent,
          padding: _getPadding(),
          minimumSize: Size(0, _getHeight()),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
        ),
        child: content,
      ),
    );
  }

  EdgeInsets _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.buttonPaddingSmall;
      case ButtonSize.medium:
        return AppSpacing.buttonPadding;
      case ButtonSize.large:
        return AppSpacing.buttonPaddingLarge;
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36;
      case ButtonSize.medium:
        return AppSpacing.minButtonHeight;
      case ButtonSize.large:
        return 56;
    }
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return AppSpacing.iconSM;
      case ButtonSize.medium:
        return AppSpacing.iconMD;
      case ButtonSize.large:
        return AppSpacing.iconLG;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case ButtonSize.small:
        return AppTypography.labelMedium;
      case ButtonSize.medium:
        return AppTypography.button;
      case ButtonSize.large:
        return AppTypography.button.copyWith(fontSize: 18);
    }
  }
}
