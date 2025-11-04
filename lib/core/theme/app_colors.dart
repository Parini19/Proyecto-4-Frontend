import 'package:flutter/material.dart';

/// Cinema App Color Palette - Modern 2025 Design
/// Inspired by Netflix, Spotify, and premium cinema experiences
/// Features: Glassmorphism, Neon accents, Dreamy gradients
class AppColors {
  // Private constructor to prevent instantiation
  AppColors._();

  // ========== BRAND COLORS (Primary - Electric Cyan/Blue) ==========
  // Trendy electric cyan for 2025 - innovative and futuristic
  static const Color primary = Color(0xFF00D9FF); // Electric Cyan
  static const Color primaryDark = Color(0xFF00B8D9); // Deep Cyan
  static const Color primaryLight = Color(0xFF5CE1E6); // Light Cyan
  static const Color primaryAccent = Color(0xFF38BDF8); // Sky Blue Accent

  // Secondary accent - Vibrant Purple for premium feel
  static const Color secondary = Color(0xFF8B5CF6); // Vibrant Purple
  static const Color secondaryDark = Color(0xFF7C3AED); // Deep Purple
  static const Color secondaryLight = Color(0xFFA78BFA); // Light Purple

  // ========== LIGHT THEME COLORS (Minimalist & Clean) ==========
  static const Color lightBackground = Color(0xFFFAFAFA); // Almost white
  static const Color lightSurface = Color(0xFFFFFFFF); // Pure White
  static const Color lightSurfaceVariant = Color(0xFFF5F5F7); // Light gray
  static const Color lightSurfaceHover = Color(0xFFEFEFF1); // Hover gray
  static const Color lightSurfaceElevated = Color(0xFFFFFFFF); // Elevated white

  static const Color lightTextPrimary = Color(0xFF0F172A); // Almost black
  static const Color lightTextSecondary = Color(0xFF475569); // Slate gray
  static const Color lightTextTertiary = Color(0xFF94A3B8); // Light slate

  static const Color lightBorder = Color(0xFFE2E8F0); // Soft border
  static const Color lightBorderLight = Color(0xFFF1F5F9); // Very light border

  // ========== DARK THEME COLORS (Premium Cinema Experience) ==========
  // Deep blacks with blue undertones - not pure black (better for eyes)
  static const Color darkBackground = Color(0xFF0A0E17); // Deep blue-black
  static const Color darkSurface = Color(0xFF12161F); // Dark surface
  static const Color darkSurfaceVariant = Color(0xFF1E2430); // Lighter surface
  static const Color darkSurfaceHover = Color(0xFF252B38); // Hover surface
  static const Color darkSurfaceElevated = Color(0xFF1A1F2E); // Elevated surface

  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Almost white
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Light slate
  static const Color darkTextTertiary = Color(0xFF64748B); // Medium slate

  static const Color darkBorder = Color(0xFF1E293B); // Dark border
  static const Color darkBorderLight = Color(0xFF334155); // Subtle border

  // ========== DYNAMIC COLORS (Context-aware) ==========
  static Color background = lightBackground;
  static Color surface = lightSurface;
  static Color surfaceVariant = lightSurfaceVariant;
  static Color surfaceHover = lightSurfaceHover;
  static Color surfaceElevated = lightSurfaceElevated;

  static Color textPrimary = lightTextPrimary;
  static Color textSecondary = lightTextSecondary;
  static Color textTertiary = lightTextTertiary;
  static Color textDisabled = const Color(0xFFCBD5E1);

  static Color border = lightBorder;
  static Color borderLight = lightBorderLight;

  // ========== SEMANTIC COLORS (Modern & Vibrant) ==========
  static const Color success = Color(0xFF10B981); // Emerald green
  static const Color successLight = Color(0xFF34D399);
  static const Color warning = Color(0xFFF59E0B); // Amber
  static const Color warningLight = Color(0xFFFBBF24);
  static const Color error = Color(0xFFEF4444); // Red
  static const Color errorLight = Color(0xFFF87171);
  static const Color info = Color(0xFF3B82F6); // Blue
  static const Color infoLight = Color(0xFF60A5FA);

  static const Color borderFocus = primary;

  // ========== GLASSMORPHISM COLORS ==========
  // Translucent surfaces for modern premium look
  static Color glassLight = Colors.white.withOpacity(0.1);
  static Color glassDark = Colors.black.withOpacity(0.2);
  static Color glassBlur = Colors.white.withOpacity(0.05);

  // ========== OVERLAY COLORS ==========
  static const Color overlay = Color(0x80000000); // 50% black
  static const Color overlayLight = Color(0x40000000); // 25% black
  static const Color scrim = Color(0xCC000000); // 80% black for modals

  // ========== GRADIENTS (Trendy 2025 Style) ==========

  // Primary gradient - Electric cyan to purple (innovative)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D9FF), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Hero gradient - For main banners and features
  static const LinearGradient heroGradient = LinearGradient(
    colors: [
      Color(0xFF1E3A8A), // Deep blue
      Color(0xFF7C3AED), // Purple
      Color(0xFFDB2777), // Pink accent
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dreamy pastel gradient - Soft and modern
  static const LinearGradient dreamyGradient = LinearGradient(
    colors: [
      Color(0xFFDDD6FE), // Light purple
      Color(0xFFFAE8FF), // Light pink
      Color(0xFFE0F2FE), // Light blue
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Dark surface gradient - Subtle depth
  static const LinearGradient darkSurfaceGradient = LinearGradient(
    colors: [Color(0xFF12161F), Color(0xFF1A1F2E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Cinema gradient - Dark with neon accent
  static const LinearGradient cinemaGradient = LinearGradient(
    colors: [
      Color(0xFF0A0E17),
      Color(0xFF1E3A8A),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ========== SHADOWS (Modern & Soft) ==========

  // Soft card shadow for light mode
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.02),
          blurRadius: 8,
          offset: const Offset(0, 1),
        ),
      ];

  // Elevated shadow for important elements
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 32,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ];

  // Glow effect for dark mode - cyan accent
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: primary.withOpacity(0.3),
          blurRadius: 24,
          offset: const Offset(0, 0),
        ),
        BoxShadow(
          color: primary.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 0),
        ),
      ];

  // Purple glow for secondary elements
  static List<BoxShadow> get purpleGlowShadow => [
        BoxShadow(
          color: secondary.withOpacity(0.3),
          blurRadius: 24,
          offset: const Offset(0, 0),
        ),
      ];

  // ========== SPECIAL FEATURE COLORS ==========
  static const Color star = Color(0xFFFBBF24); // Gold star
  static const Color starEmpty = Color(0xFF64748B); // Gray empty

  static const Color premium = Color(0xFFFFD700); // Gold
  static const Color vip = Color(0xFF8B5CF6); // Purple
  static const Color imax = Color(0xFF00D9FF); // Cyan

  // Seat colors (modern palette)
  static const Color seatAvailable = Color(0xFF10B981); // Green
  static const Color seatSelected = Color(0xFF00D9FF); // Cyan
  static const Color seatOccupied = Color(0xFF64748B); // Gray
  static const Color seatVIP = Color(0xFFFFD700); // Gold

  // ========== NEON ACCENTS (2025 Trend) ==========
  static const Color neonCyan = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF006E);
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonPurple = Color(0xFFBF40BF);
}
