import 'package:flutter/material.dart';

/// Taskko color tokens — authoritative source is SRS §7.
/// Do not hard-code hex anywhere else; reference these constants.
abstract final class AppColors {
  // Primary (sky blue)
  static const Color primary = Color(0xFF1FB6F0);
  static const Color primary2 = Color(0xFF5BCBF5);
  static const Color primarySoft = Color(0xFFDDF3FE);
  static const Color primaryDeep = Color(0xFF0E8FC4);

  // Energy / streak (peach)
  static const Color energy = Color(0xFFFF8A65);
  static const Color energySoft = Color(0xFFFFE6DD);

  // Success / done (mint)
  static const Color mint = Color(0xFF34D399);
  static const Color mintSoft = Color(0xFFD6F5E6);

  // Accents
  static const Color gold = Color(0xFFF5C544);
  static const Color goldSoft = Color(0xFFFFF1C9);
  static const Color rose = Color(0xFFF472B6);
  static const Color lavender = Color(0xFFC7B8FF);

  // Ink (text)
  static const Color ink = Color(0xFF0F0F1A);
  static const Color ink2 = Color(0xFF2E2E3F);
  static const Color ink3 = Color(0xFF6B6B82);
  static const Color ink4 = Color(0xFFA8A8BC);

  // Lines & surfaces
  static const Color line = Color(0xFFECECF3);
  static const Color line2 = Color(0xFFDCDCE7);
  static const Color surface = Color(0xFFFFFFFF);

  // Background — mint + lilac tinted neutral
  static const Color background = Color(0xFFF4F4FB);
  static const Color backgroundLilac = Color(0xFFF1F0FB);
  static const Color backgroundMint = Color(0xFFEAF7F1);

  /// Subtle full-screen background gradient (lilac → mint).
  static const LinearGradient bgGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [backgroundLilac, backgroundMint],
  );

  /// Primary CTA gradient (used on hero buttons / logo).
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary2, primaryDeep],
  );

  /// Streak / energy gradient.
  static const LinearGradient energyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFB199), energy],
  );

  // Splash — deep navy backdrop (SRS FR-1).
  static const Color splashTop = Color(0xFF1B2140);
  static const Color splashBottom = Color(0xFF0E1124);
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [splashTop, splashBottom],
  );

  /// Auth screens — soft blue top fading into the app background.
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFE7F4FD), background],
    stops: [0.0, 0.45],
  );

  // Google brand blue (used only for the "G" glyph on the sign-in button).
  static const Color google = Color(0xFF4285F4);
  static const Color ink0 = Color(0xFF0F0F1A);
}
