import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Mood check-in options (SRS FR-4.4, FR-9). Order matches the Home frame.
enum Mood {
  firedUp('Fired up', '🔥', AppColors.energy),
  focused('Focused', '🎯', AppColors.primary),
  chill('Chill', '🌿', AppColors.mint),
  drained('Drained', '😮‍💨', AppColors.lavender);

  const Mood(this.label, this.emoji, this.color);

  final String label;
  final String emoji;
  final Color color;
}
