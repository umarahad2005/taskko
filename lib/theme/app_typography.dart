import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Taskko typography (SRS §7):
/// - Manrope  → UI / body
/// - Fraunces → display / headlines
/// - JetBrains Mono → stats / timers / points
abstract final class AppTypography {
  static TextStyle display(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: weight, color: color ?? AppColors.ink, height: 1.1);

  static TextStyle ui(double size, {Color? color, FontWeight weight = FontWeight.w600, double? height}) =>
      GoogleFonts.manrope(fontSize: size, fontWeight: weight, color: color ?? AppColors.ink, height: height);

  static TextStyle mono(double size, {Color? color, FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: weight, color: color ?? AppColors.ink);

  /// Builds the Material [TextTheme] (Manrope base + Fraunces display).
  static TextTheme textTheme() {
    final base = GoogleFonts.manropeTextTheme();
    return base.copyWith(
      displayLarge: display(34),
      displayMedium: display(28),
      displaySmall: display(24),
      headlineMedium: ui(20, weight: FontWeight.w800),
      titleLarge: ui(18, weight: FontWeight.w700),
      titleMedium: ui(16, weight: FontWeight.w700),
      bodyLarge: ui(15, weight: FontWeight.w500, color: AppColors.ink2),
      bodyMedium: ui(14, weight: FontWeight.w500, color: AppColors.ink3),
      labelLarge: ui(14, weight: FontWeight.w700),
      labelSmall: ui(12, weight: FontWeight.w700, color: AppColors.ink3),
    );
  }
}
