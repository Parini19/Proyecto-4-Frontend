import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';
import 'app_typography.dart';
import 'app_spacing.dart';

/// Cinema App Theme - Modern 2025 Design
/// Features: Glassmorphism, Neon accents, Premium dark/light modes
class AppTheme {
  AppTheme._();

  /// Light Theme - Minimalist & Clean (iOS/Modern style)
  static ThemeData get lightTheme {
    return _buildTheme(
      brightness: Brightness.light,
      background: AppColors.lightBackground,
      surface: AppColors.lightSurface,
      surfaceVariant: AppColors.lightSurfaceVariant,
      surfaceElevated: AppColors.lightSurfaceElevated,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      textTertiary: AppColors.lightTextTertiary,
      border: AppColors.lightBorder,
      borderLight: AppColors.lightBorderLight,
      statusBarIconBrightness: Brightness.dark,
      isDark: false,
    );
  }

  /// Dark Theme - Premium Cinema Experience
  static ThemeData get darkTheme {
    return _buildTheme(
      brightness: Brightness.dark,
      background: AppColors.darkBackground,
      surface: AppColors.darkSurface,
      surfaceVariant: AppColors.darkSurfaceVariant,
      surfaceElevated: AppColors.darkSurfaceElevated,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      textTertiary: AppColors.darkTextTertiary,
      border: AppColors.darkBorder,
      borderLight: AppColors.darkBorderLight,
      statusBarIconBrightness: Brightness.light,
      isDark: true,
    );
  }

  /// Build theme with given colors
  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color surfaceElevated,
    required Color textPrimary,
    required Color textSecondary,
    required Color textTertiary,
    required Color border,
    required Color borderLight,
    required Brightness statusBarIconBrightness,
    required bool isDark,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      // Color Scheme - Modern 2025 palette
      colorScheme: ColorScheme(
        brightness: brightness,
        // Primary - Electric Cyan
        primary: AppColors.primary,
        onPrimary: isDark ? AppColors.darkTextPrimary : Colors.white,
        primaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        onPrimaryContainer: isDark ? AppColors.primaryLight : AppColors.primaryDark,
        // Secondary - Vibrant Purple
        secondary: AppColors.secondary,
        onSecondary: Colors.white,
        secondaryContainer: isDark ? AppColors.secondaryDark : AppColors.secondaryLight,
        onSecondaryContainer: isDark ? AppColors.secondaryLight : AppColors.secondaryDark,
        // Tertiary - Additional accent
        tertiary: AppColors.primaryAccent,
        onTertiary: Colors.white,
        tertiaryContainer: isDark ? AppColors.primaryDark : AppColors.primaryLight,
        onTertiaryContainer: textPrimary,
        // Error colors
        error: AppColors.error,
        onError: Colors.white,
        errorContainer: AppColors.errorLight,
        onErrorContainer: AppColors.error,
        // Surface colors
        surface: surface,
        onSurface: textPrimary,
        surfaceContainerHighest: surfaceVariant,
        onSurfaceVariant: textSecondary,
        // Borders
        outline: border,
        outlineVariant: borderLight,
        // Shadows
        shadow: Colors.black,
        scrim: AppColors.scrim,
        // Inverse colors
        inverseSurface: isDark ? AppColors.lightSurface : AppColors.darkSurface,
        onInverseSurface: isDark ? AppColors.lightTextPrimary : AppColors.darkTextPrimary,
        inversePrimary: isDark ? AppColors.primaryLight : AppColors.primaryDark,
      ),

      // Scaffold
      scaffoldBackgroundColor: background,

      // App Bar - Modern flat style
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.titleLarge.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: statusBarIconBrightness,
          systemNavigationBarColor: surface,
          systemNavigationBarIconBrightness: statusBarIconBrightness,
        ),
      ),

      // Text Theme
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(color: textPrimary),
        displayMedium: AppTypography.displayMedium.copyWith(color: textPrimary),
        displaySmall: AppTypography.displaySmall.copyWith(color: textPrimary),
        headlineLarge: AppTypography.headlineLarge.copyWith(color: textPrimary),
        headlineMedium: AppTypography.headlineMedium.copyWith(color: textPrimary),
        headlineSmall: AppTypography.headlineSmall.copyWith(color: textPrimary),
        titleLarge: AppTypography.titleLarge.copyWith(color: textPrimary),
        titleMedium: AppTypography.titleMedium.copyWith(color: textPrimary),
        titleSmall: AppTypography.titleSmall.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTypography.bodyMedium.copyWith(color: textPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: textSecondary),
        labelLarge: AppTypography.labelLarge.copyWith(color: textPrimary),
        labelMedium: AppTypography.labelMedium.copyWith(color: textSecondary),
        labelSmall: AppTypography.labelSmall.copyWith(color: textSecondary),
      ),

      // Card Theme - Modern with subtle shadow
      cardTheme: CardThemeData(
        color: surfaceElevated,
        elevation: isDark ? 2 : 0,
        shadowColor: isDark ? Colors.black38 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
        margin: EdgeInsets.zero,
      ),

      // Elevated Button - Modern gradient style
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: isDark ? AppColors.darkTextPrimary : Colors.white,
          disabledBackgroundColor: surfaceVariant,
          elevation: isDark ? 4 : 0,
          shadowColor: isDark ? AppColors.primary.withOpacity(0.3) : null,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.minButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(
            color: AppColors.primary,
            width: 2,
          ),
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.minButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.minButtonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: AppSpacing.borderRadiusSM,
          ),
          textStyle: AppTypography.button.copyWith(fontWeight: FontWeight.w600),
        ),
      ),

      // Input Decoration - Modern glassmorphism style
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: AppSpacing.inputPadding,
        border: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide(color: borderLight, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppSpacing.borderRadiusSM,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        labelStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
        hintStyle: AppTypography.bodyMedium.copyWith(color: textTertiary),
        errorStyle: AppTypography.labelSmall.copyWith(color: AppColors.error),
      ),

      // Chip Theme - Modern pill style
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: AppColors.primary,
        disabledColor: surfaceVariant.withOpacity(0.5),
        padding: AppSpacing.paddingSM,
        labelStyle: AppTypography.labelMedium.copyWith(color: textPrimary),
        secondaryLabelStyle: AppTypography.labelMedium.copyWith(
          color: isDark ? AppColors.darkTextPrimary : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusRound,
        ),
        elevation: 0,
        side: BorderSide.none,
      ),

      // Bottom Navigation Bar - Modern glassmorphism
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark
            ? surfaceElevated.withOpacity(0.95)
            : surface,
        indicatorColor: AppColors.primary.withOpacity(isDark ? 0.2 : 0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppTypography.labelSmall.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            );
          }
          return AppTypography.labelSmall.copyWith(color: textSecondary);
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: AppColors.primary, size: 26);
          }
          return IconThemeData(color: textSecondary, size: 24);
        }),
        elevation: isDark ? 8 : 0,
        height: 70,
        shadowColor: isDark ? Colors.black38 : null,
      ),

      // Dialog Theme - Modern with blur effect
      dialogTheme: DialogThemeData(
        backgroundColor: surfaceElevated,
        elevation: 8,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusLG,
        ),
        titleTextStyle: AppTypography.headlineSmall.copyWith(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: AppTypography.bodyMedium.copyWith(color: textSecondary),
      ),

      // Bottom Sheet Theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surfaceElevated,
        elevation: 8,
        shadowColor: isDark ? Colors.black54 : Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
        modalBackgroundColor: surfaceElevated,
        modalElevation: 8,
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: border,
        thickness: 1,
        space: AppSpacing.md,
      ),

      // Icon Theme
      iconTheme: IconThemeData(
        color: textPrimary,
        size: 24,
      ),

      // Progress Indicator Theme - Cyan accent
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
        circularTrackColor: AppColors.primary.withOpacity(0.2),
      ),

      // Floating Action Button Theme - Gradient style
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: isDark ? AppColors.darkTextPrimary : Colors.white,
        elevation: isDark ? 8 : 4,
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusRound,
        ),
      ),

      // Switch Theme - Modern toggle
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return textSecondary;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary.withOpacity(0.5);
          }
          return border;
        }),
      ),

      // Checkbox Theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(
          isDark ? AppColors.darkTextPrimary : Colors.white,
        ),
        side: BorderSide(color: border, width: 2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio Theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return border;
        }),
      ),

      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.primary.withOpacity(0.3),
        thumbColor: AppColors.primary,
        overlayColor: AppColors.primary.withOpacity(0.2),
        trackHeight: 4,
      ),

      // Snackbar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: isDark ? surfaceElevated : textPrimary,
        contentTextStyle: AppTypography.bodyMedium.copyWith(
          color: isDark ? textPrimary : Colors.white,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 4,
      ),

      // Tooltip Theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? surfaceElevated : textPrimary,
          borderRadius: AppSpacing.borderRadiusSM,
        ),
        textStyle: AppTypography.labelSmall.copyWith(
          color: isDark ? textPrimary : Colors.white,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
      ),
    );
  }
}
