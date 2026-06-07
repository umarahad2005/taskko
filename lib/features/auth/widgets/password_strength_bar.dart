import 'package:flutter/material.dart';

import '../../../common/validators.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// Three-segment password strength meter (SRS FR-3.1).
class PasswordStrengthBar extends StatelessWidget {
  const PasswordStrengthBar({super.key, required this.strength});

  final PasswordStrength strength;

  @override
  Widget build(BuildContext context) {
    final lit = switch (strength) {
      PasswordStrength.weak => 1,
      PasswordStrength.fair => 2,
      PasswordStrength.strong => 3,
    };
    final color = switch (strength) {
      PasswordStrength.weak => AppColors.energy,
      PasswordStrength.fair => AppColors.gold,
      PasswordStrength.strong => AppColors.mint,
    };
    final label = switch (strength) {
      PasswordStrength.weak => 'Weak',
      PasswordStrength.fair => 'Fair',
      PasswordStrength.strong => 'Strong',
    };

    return Row(
      children: [
        for (var i = 0; i < 3; i++) ...[
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: i < lit ? color : AppColors.line2,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          if (i < 2) const SizedBox(width: 6),
        ],
        const SizedBox(width: 10),
        Text(label, style: AppTypography.ui(11, color: color, weight: FontWeight.w700)),
      ],
    );
  }
}
