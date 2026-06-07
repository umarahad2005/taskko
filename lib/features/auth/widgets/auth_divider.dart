import 'package:flutter/material.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';

/// "OR SIGN UP WITH EMAIL" style separator.
class AuthDivider extends StatelessWidget {
  const AuthDivider({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: AppColors.line2)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            label.toUpperCase(),
            style: AppTypography.ui(11, color: AppColors.ink4, weight: FontWeight.w800).copyWith(letterSpacing: 0.8),
          ),
        ),
        const Expanded(child: Divider(color: AppColors.line2)),
      ],
    );
  }
}
