import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/app_spacing.dart';

class CinemaTextField extends StatefulWidget {
  final String label;
  final String? hint;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final int? maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;

  const CinemaTextField({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.validator,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.onSubmitted,
    this.textCapitalization,
    this.inputFormatters,
    this.onTap,
  });

  @override
  State<CinemaTextField> createState() => _CinemaTextFieldState();
}

class _CinemaTextFieldState extends State<CinemaTextField> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: widget.onTap,
      child: TextFormField(
        controller: widget.controller,
        validator: widget.validator,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        enabled: widget.enabled,
        onChanged: widget.onChanged,
        onFieldSubmitted: widget.onSubmitted,
        onTap: widget.onTap,
        textCapitalization: widget.textCapitalization ?? TextCapitalization.none,
        inputFormatters: widget.inputFormatters,
        style: AppTypography.bodyLarge.copyWith(
          color: widget.enabled
              ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
              : AppColors.textDisabled,
        ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            fontSize: 16,
            height: 1.2,
          ),
          floatingLabelStyle: AppTypography.bodySmall.copyWith(
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          hintText: widget.hint,
          hintStyle: AppTypography.bodyMedium.copyWith(
            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            fontSize: 15,
          ),
          prefixIcon: widget.prefixIcon != null
              ? Icon(
                  widget.prefixIcon,
                  color: widget.enabled
                      ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                      : AppColors.textDisabled,
                )
              : null,
          suffixIcon: widget.obscureText
              ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility : Icons.visibility_off,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
              : widget.suffixIcon,
          filled: true,
          fillColor: widget.enabled
              ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
              : (isDark ? AppColors.darkSurfaceVariant.withOpacity(0.5) : AppColors.lightSurfaceVariant.withOpacity(0.5)),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.lg,
          ),
          border: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSM,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSM,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSM,
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSM,
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSM,
            borderSide: const BorderSide(
              color: AppColors.error,
              width: 2,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: AppSpacing.borderRadiusSM,
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
