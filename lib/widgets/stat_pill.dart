import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Compact stat chip — numeric content uses the JetBrains Mono token (SRS §7).
class StatPill extends StatelessWidget {
  const StatPill({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.primary,
    this.background,
    this.mono = true,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? background;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
      decoration: BoxDecoration(
        color: background ?? color.withValues(alpha: 0.12),
        borderRadius: AppRadii.pillRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: AppSpacing.xs),
          ],
          Text(
            label,
            style: mono
                ? AppTypography.mono(12, color: color)
                : AppTypography.ui(12, color: color, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
