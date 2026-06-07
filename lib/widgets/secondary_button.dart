import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radii.dart';
import '../theme/app_typography.dart';

/// Lower-emphasis action paired with [PrimaryButton] (e.g. "Skip").
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = AppColors.primary,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.lgRadius,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          decoration: BoxDecoration(
            color: filled ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: AppRadii.lgRadius,
            border: filled ? null : Border.all(color: AppColors.line2),
          ),
          child: Text(label, style: AppTypography.ui(16, color: color, weight: FontWeight.w700)),
        ),
      ),
    );
  }
}
