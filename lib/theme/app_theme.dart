import 'package:flutter/material.dart';

/// EcoSort branding: forest / moss green + orange accent.
///
/// Hex values (from the project brief):
///   Primary   #1F4E3D  (deep forest)
///   Secondary #7CA982  (moss)
///   Accent    #E8871E  (amber — CTAs, warnings)
///   Surface   #FFFFFF
class AppColors {
  static const Color primary = Color(0xFF1F4E3D);
  static const Color secondary = Color(0xFF7CA982);
  static const Color accent = Color(0xFFE8871E);
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF4F7F5);
  static const Color textDark = Color(0xFF1A2E26);
  static const Color textMuted = Color(0xFF5C6B64);

  /// Fill-level traffic lights used on badges and map dots.
  static const Color fillGreen = Color(0xFF2E8B57);
  static const Color fillYellow = Color(0xFFD4A017);
  static const Color fillRed = Color(0xFFC44536);
}

class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      surface: AppColors.background,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppColors.secondary.withValues(alpha: 0.35)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.secondary.withValues(alpha: 0.35),
        labelTextStyle: WidgetStatePropertyAll(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
