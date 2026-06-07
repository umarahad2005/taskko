import 'package:flutter/widgets.dart';

/// Spacing scale (SRS §7 — bento layout).
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard horizontal gutter for phone screens (402px reference frame).
  static const double gutter = 20;
}

/// Corner radii — bento cards ~20–28px (SRS §7).
abstract final class AppRadii {
  static const double sm = 12;
  static const double md = 16;
  static const double card = 24;
  static const double lg = 28;
  static const double pill = 999;

  static const BorderRadius cardRadius = BorderRadius.all(Radius.circular(card));
  static const BorderRadius lgRadius = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius pillRadius = BorderRadius.all(Radius.circular(pill));
}
