import 'package:flutter/material.dart';

import '../../../models/mood.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/stat_pill.dart';
import '../../../widgets/tako_mascot.dart';

/// One onboarding slide: headline, supporting copy, and an illustration.
class OnboardingSlide {
  const OnboardingSlide({required this.title, required this.body, required this.illustration});

  final String title;
  final String body;
  final Widget illustration;

  static const List<OnboardingSlide> slides = [
    OnboardingSlide(
      title: 'Big goals,\nbroken down.',
      body: 'Drop a goal — "prep for midterm", "finish capstone" — and Tako turns it into a guided plan you can actually start.',
      illustration: _PlanIllustration(),
    ),
    OnboardingSlide(
      title: 'Show up,\nevery day.',
      body: 'Streaks, shields and ranks turn consistency into a game — climb from Rookie to Legend, one task at a time.',
      illustration: _StreaksIllustration(),
    ),
    OnboardingSlide(
      title: 'Better with\nyour squad.',
      body: 'Share badges, compare weekly report cards, and climb the leaderboard with friends. Accountability that feels good.',
      illustration: _SquadIllustration(),
    ),
  ];
}

class _PlanIllustration extends StatelessWidget {
  const _PlanIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Align(alignment: Alignment.centerRight, child: TakoMascot(size: 64)),
        const SizedBox(height: AppSpacing.md),
        BentoCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('GOAL', style: AppTypography.ui(10, color: AppColors.primary, weight: FontWeight.w800)),
              const SizedBox(height: 2),
              Text('Prep CS-201 midterm', style: AppTypography.ui(16, weight: FontWeight.w700)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const _MiniTask(text: 'Re-read chapters 5 & 6', done: true),
        const SizedBox(height: AppSpacing.sm),
        const _MiniTask(text: 'Solve 10 problems'),
        const SizedBox(height: AppSpacing.sm),
        const _MiniTask(text: 'Build a cheat sheet'),
      ],
    );
  }
}

class _MiniTask extends StatelessWidget {
  const _MiniTask({required this.text, this.done = false});
  final String text;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadii.cardRadius),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: done ? AppColors.mint : AppColors.surface,
              borderRadius: BorderRadius.circular(7),
              border: done ? null : Border.all(color: AppColors.line2),
            ),
            child: done ? const Icon(Icons.check_rounded, size: 15, color: Colors.white) : null,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(text, style: AppTypography.ui(14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StreaksIllustration extends StatelessWidget {
  const _StreaksIllustration();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const TakoMascot(size: 64, mood: Mood.firedUp),
        const SizedBox(height: AppSpacing.lg),
        BentoCard(
          gradient: AppColors.energyGradient,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('5', style: AppTypography.mono(48, color: Colors.white)),
              Text('DAY STREAK', style: AppTypography.ui(12, color: Colors.white, weight: FontWeight.w800)),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++) ...[
                    Container(
                      width: 26,
                      height: 8,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(99)),
                    ),
                    if (i < 4) const SizedBox(width: 6),
                  ],
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        const StatPill(label: 'Rank: Pro', icon: Icons.emoji_events_rounded),
      ],
    );
  }
}

class _SquadIllustration extends StatelessWidget {
  const _SquadIllustration();

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          _LeaderRow(rank: 1, name: 'Ali', points: '2,310', color: AppColors.gold),
          SizedBox(height: AppSpacing.md),
          _LeaderRow(rank: 2, name: 'You', points: '1,240', color: AppColors.primary, you: true),
          SizedBox(height: AppSpacing.md),
          _LeaderRow(rank: 3, name: 'Zara', points: '980', color: AppColors.energy),
        ],
      ),
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.rank, required this.name, required this.points, required this.color, this.you = false});
  final int rank;
  final String name;
  final String points;
  final Color color;
  final bool you;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: you ? AppColors.primarySoft : Colors.transparent,
        borderRadius: AppRadii.cardRadius,
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 16, backgroundColor: color, child: Text('$rank', style: AppTypography.ui(13, color: Colors.white, weight: FontWeight.w800))),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(name, style: AppTypography.ui(15, weight: FontWeight.w700))),
          Text('$points pts', style: AppTypography.mono(13, color: AppColors.ink3)),
        ],
      ),
    );
  }
}
