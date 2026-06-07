import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// Original Taskko mark: a gradient sky-blue squircle + checkmark ("mark done")
/// with a peach spark. Encodes the verb and the two product pillars (SRS §8).
class TaskkoLogo extends StatelessWidget {
  const TaskkoLogo({super.key, this.size = 40, this.showWordmark = false, this.onLight = true});

  final double size;
  final bool showWordmark;
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final mark = SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(size * 0.32),
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: size * 0.62),
          ),
          Positioned(
            right: -size * 0.06,
            top: -size * 0.06,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: const BoxDecoration(color: AppColors.energy, shape: BoxShape.circle),
            ),
          ),
        ],
      ),
    );

    if (!showWordmark) return mark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mark,
        const SizedBox(width: 10),
        Text(
          'taskko',
          style: AppTypography.ui(22, weight: FontWeight.w800, color: onLight ? AppColors.ink : Colors.white),
        ),
      ],
    );
  }
}
