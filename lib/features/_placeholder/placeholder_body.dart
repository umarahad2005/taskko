import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';
import '../../theme/app_radii.dart';

/// Temporary scaffolding body used by M1 placeholder screens. Each is replaced
/// by its real implementation in the milestone that owns it (M2–M6).
class PlaceholderBody extends StatelessWidget {
  const PlaceholderBody({super.key, required this.title, required this.milestone, this.actions = const []});

  final String title;
  final String milestone;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              decoration: BoxDecoration(color: AppColors.primarySoft, borderRadius: AppRadii.pillRadius),
              child: Text(milestone, style: AppTypography.mono(12, color: AppColors.primaryDeep)),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(title, style: AppTypography.display(26), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text('Coming in this milestone.', style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w500)),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xxl),
              ...actions,
            ],
          ],
        ),
      ),
    );
  }
}
