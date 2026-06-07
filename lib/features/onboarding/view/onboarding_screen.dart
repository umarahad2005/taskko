import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../cubits/onboarding/onboarding_cubit.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/primary_button.dart';
import '../../../widgets/taskko_logo.dart';
import '../widgets/onboarding_slides.dart';

/// Onboarding tour (SRS FR-2): 3 slides Plan → Streaks → Squad, dot indicator,
/// Skip (top-right) and Next / Get started → Sign up.
class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(create: (_) => OnboardingCubit(), child: const _OnboardingBody());
  }
}

class _OnboardingBody extends StatefulWidget {
  const _OnboardingBody();

  @override
  State<_OnboardingBody> createState() => _OnboardingBodyState();
}

class _OnboardingBodyState extends State<_OnboardingBody> {
  final _pc = PageController();

  static const _slides = OnboardingSlide.slides;

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _next() {
    final cubit = context.read<OnboardingCubit>();
    if (cubit.isLast) {
      context.go('/signup');
    } else {
      _pc.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppColors.authGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, AppSpacing.sm, AppSpacing.gutter, 0),
                child: Row(
                  children: [
                    const TaskkoLogo(size: 28, showWordmark: true),
                    const Spacer(),
                    TextButton(
                      onPressed: () => context.go('/signup'),
                      child: Text('Skip', style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: _slides.length,
                  onPageChanged: (i) => context.read<OnboardingCubit>().setPage(i),
                  itemBuilder: (_, i) => _SlideView(slide: _slides[i]),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.gutter, 0, AppSpacing.gutter, AppSpacing.lg),
                child: Column(
                  children: [
                    BlocBuilder<OnboardingCubit, int>(
                      builder: (context, index) => Row(
                        children: [
                          for (var i = 0; i < _slides.length; i++) ...[
                            _Dot(active: i == index),
                            const SizedBox(width: 6),
                          ],
                          const Spacer(),
                          Text('${index + 1}/${_slides.length}',
                              style: AppTypography.mono(13, color: AppColors.ink3)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    BlocBuilder<OnboardingCubit, int>(
                      builder: (context, index) => PrimaryButton(
                        label: index == _slides.length - 1 ? 'Get started' : 'Next',
                        icon: Icons.arrow_forward_rounded,
                        onPressed: _next,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SlideView extends StatelessWidget {
  const _SlideView({required this.slide});
  final OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Center(child: slide.illustration)),
          Text(slide.title, style: AppTypography.display(30)),
          const SizedBox(height: AppSpacing.md),
          Text(slide.body, style: AppTypography.ui(15, color: AppColors.ink3, weight: FontWeight.w500, height: 1.5)),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.active});
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      height: 6,
      width: active ? 22 : 6,
      decoration: BoxDecoration(
        color: active ? AppColors.ink : AppColors.line2,
        borderRadius: BorderRadius.circular(99),
      ),
    );
  }
}
