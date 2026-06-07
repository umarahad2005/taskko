import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Small uppercase section label with an optional trailing widget/action.
class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title.toUpperCase(),
          style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w800)
              .copyWith(letterSpacing: 1.1),
        ),
        ?trailing,
      ],
    );
  }
}
