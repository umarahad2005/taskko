import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/taskko_logo.dart';

/// Splash (SRS FR-1) — deep-navy brand moment. Auto-advances to onboarding
/// after ~2.4s. Real auth-state routing (returning user → Home) lands in M3+.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 2400), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Subtle decorative blobs (top-right cool, bottom-left warm).
            Positioned(
              top: -60,
              right: -50,
              child: _blob(220, AppColors.primary.withValues(alpha: 0.18)),
            ),
            Positioned(
              bottom: -70,
              left: -60,
              child: _blob(200, AppColors.energy.withValues(alpha: 0.12)),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          blurRadius: 48,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                    child: const TaskkoLogo(size: 96),
                  ),
                  const SizedBox(height: 24),
                  Text('taskko', style: AppTypography.display(40, color: Colors.white)),
                  const SizedBox(height: 8),
                  Text(
                    'your AI productivity companion',
                    style: AppTypography.ui(14, color: Colors.white70, weight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            // Loading affordance.
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: Column(
                children: [
                  SizedBox(
                    width: 120,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(99),
                      child: const LinearProgressIndicator(
                        minHeight: 3,
                        backgroundColor: Colors.white24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('loading…', style: AppTypography.ui(12, color: Colors.white60, weight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
