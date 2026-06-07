import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';

/// White Google / black Apple sign-in buttons (SRS FR-3.3).
class SocialButton extends StatelessWidget {
  const SocialButton.google({super.key, required this.onPressed})
      : label = 'Continue with Google',
        dark = false,
        glyph = const _GoogleGlyph();

  const SocialButton.apple({super.key, required this.onPressed})
      : label = 'Continue with Apple',
        dark = true,
        glyph = const Icon(Icons.apple, color: Colors.white, size: 22);

  final String label;
  final bool dark;
  final Widget glyph;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: AppRadii.cardRadius,
        child: Container(
          height: 54,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? AppColors.ink0 : AppColors.surface,
            borderRadius: AppRadii.cardRadius,
            border: dark ? null : Border.all(color: AppColors.line2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              glyph,
              const SizedBox(width: AppSpacing.md),
              Text(
                label,
                style: AppTypography.ui(15, color: dark ? Colors.white : AppColors.ink, weight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleGlyph extends StatelessWidget {
  const _GoogleGlyph();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      child: Text('G', style: AppTypography.ui(18, color: AppColors.google, weight: FontWeight.w800)),
    );
  }
}
