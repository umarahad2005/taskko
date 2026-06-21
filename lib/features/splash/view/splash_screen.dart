import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/auth/auth_cubit.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/taskko_logo.dart';

/// Splash (SRS FR-1) — a one-shot staggered entrance, then a continuous explicit
/// sine "wave": the star and wordmark bob up/down with a phase offset so they
/// ripple. After the brand beat it restores any persisted session.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Entrance (plays once).
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..forward();

  // Wave (explicit controller + repeater, runs forever).
  late final AnimationController _wave = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack),
  );
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
  );
  late final Animation<double> _titleFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.30, 0.70, curve: Curves.easeOut),
  );
  late final Animation<double> _subtitleFade = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.45, 0.85, curve: Curves.easeOut),
  );

  @override
  void initState() {
    super.initState();
    _route();
  }

  @override
  void dispose() {
    _c.dispose();
    _wave.dispose();
    super.dispose();
  }

  /// Wrap [child] in a vertical sine wave driven by [_wave]. [phase] offsets the
  /// motion so stacked elements ripple instead of moving together. [amplitude]
  /// is the peak travel in logical pixels.
  Widget _waved(Widget child, {double phase = 0, double amplitude = 12}) {
    return AnimatedBuilder(
      animation: _wave,
      builder: (context, c) => Transform.translate(
        offset: Offset(0, amplitude * math.sin(2 * math.pi * _wave.value + phase)),
        child: c,
      ),
      child: child,
    );
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 2400));
    if (!mounted) return;
    final auth = context.read<AuthCubit>();
    // Wait for the persisted-session check to resolve (falls back to signed-out).
    var state = auth.state;
    if (state.status == AuthStatus.unknown) {
      state = await auth.stream.firstWhere((s) => s.status != AuthStatus.unknown).timeout(
            const Duration(seconds: 3),
            onTimeout: () => const AuthState(status: AuthStatus.unauthenticated),
          );
    }
    if (!mounted) return;
    if (state.status == AuthStatus.authenticated) {
      context.go(state.isAdmin ? '/admin' : '/home');
    } else if (state.status == AuthStatus.unverified) {
      context.go('/verify-email');
    } else {
      context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.splashGradient),
        child: Stack(
          children: [
            // Subtle decorative blobs fade in with the brand beat.
            FadeTransition(
              opacity: _logoFade,
              child: Stack(
                children: [
                  Positioned(top: -60, right: -50, child: _blob(220, AppColors.primary.withValues(alpha: 0.18))),
                  Positioned(bottom: -70, left: -60, child: _blob(200, AppColors.energy.withValues(alpha: 0.12))),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // The "star" logo waves first…
                  _waved(
                    FadeTransition(
                      opacity: _logoFade,
                      child: ScaleTransition(
                        scale: _logoScale,
                        child: DecoratedBox(
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
                      ),
                    ),
                    amplitude: 14,
                  ),
                  const SizedBox(height: 24),
                  // …then the wordmark, a beat behind…
                  _waved(
                    FadeTransition(
                      opacity: _titleFade,
                      child: Text('taskko', style: AppTypography.display(40, color: Colors.white)),
                    ),
                    phase: -0.7,
                    amplitude: 10,
                  ),
                  const SizedBox(height: 8),
                  // …then the tagline, further behind — a travelling wave.
                  _waved(
                    FadeTransition(
                      opacity: _subtitleFade,
                      child: Text(
                        'your AI productivity companion',
                        style: AppTypography.ui(14, color: Colors.white70, weight: FontWeight.w500),
                      ),
                    ),
                    phase: -1.4,
                    amplitude: 8,
                  ),
                ],
              ),
            ),
            // Loading affordance.
            Positioned(
              left: 0,
              right: 0,
              bottom: 56,
              child: FadeTransition(
                opacity: _subtitleFade,
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
