import 'package:flutter/material.dart';

import '../models/mood.dart';
import '../theme/app_colors.dart';

/// "Tako" — Taskko's original mascot: an abstract gradient spark orb (no animal,
/// only simple geometric shapes per the design brief). Expression shifts subtly
/// with [mood]; [size] scales the whole mark.
class TakoMascot extends StatelessWidget {
  const TakoMascot({super.key, this.size = 44, this.mood = Mood.focused});

  final double size;
  final Mood mood;

  @override
  Widget build(BuildContext context) {
    final eyeH = size * 0.16;
    return SizedBox(
      width: size,
      height: size * 1.12,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Antenna spark
          Positioned(
            top: 0,
            child: Container(
              width: size * 0.16,
              height: size * 0.16,
              decoration: const BoxDecoration(color: AppColors.energy, shape: BoxShape.circle),
            ),
          ),
          // Body — gradient squircle
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary2, mood.color],
              ),
              borderRadius: BorderRadius.circular(size * 0.34),
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _eye(eyeH),
                  SizedBox(width: size * 0.16),
                  _eye(eyeH),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _eye(double h) => Container(
        width: h * 0.7,
        height: h,
        decoration: BorderRadius.circular(h).toDecoration(),
      );
}

extension on BorderRadius {
  BoxDecoration toDecoration() => BoxDecoration(color: Colors.white, borderRadius: this);
}
