import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_typography.dart';

/// Assembles the single light [ThemeData] for Taskko (light mode only).
abstract final class AppTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      surface: AppColors.surface,
      onSurface: AppColors.ink,
      error: AppColors.rose,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: AppTypography.textTheme(),
      splashFactory: InkRipple.splashFactory,
      // iOS-style slide transitions + left-edge swipe-to-go-back on Android too,
      // so pushed routes (profile, settings, history, …) feel native and support
      // the standard back gesture.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      // Floating, rounded, branded snackbars (instead of the default square bar
      // that hugged the bottom edge) — they slide/fade in above the nav bar.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.ink,
        contentTextStyle: AppTypography.ui(14, color: Colors.white, weight: FontWeight.w600),
        actionTextColor: AppColors.primary,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.lgRadius),
        elevation: 8,
        insetPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.ink,
        centerTitle: false,
      ),
      dividerColor: AppColors.line,
      cardColor: AppColors.surface,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: const BorderSide(color: AppColors.line2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: const BorderSide(color: AppColors.line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.cardRadius,
          borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
        ),
        hintStyle: AppTypography.ui(14, color: AppColors.ink4, weight: FontWeight.w500),
      ),
    );
  }
}
