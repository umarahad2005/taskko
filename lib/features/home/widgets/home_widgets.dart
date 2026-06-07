import 'package:flutter/material.dart';

import '../../../models/mood.dart';
import '../../../models/rank.dart';
import '../../../models/task_item.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../../../widgets/tako_mascot.dart';

/// Streak card — peach, with a 5-day visualizer + shields (FR-4.2).
class StreakCard extends StatelessWidget {
  const StreakCard({super.key, required this.days, required this.shields});
  final int days;
  final int shields;

  @override
  Widget build(BuildContext context) {
    final lit = days.clamp(0, 5);
    return BentoCard(
      color: AppColors.energySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.local_fire_department_rounded, color: AppColors.energy, size: 16),
            const SizedBox(width: 6),
            Text('STREAK', style: AppTypography.ui(11, color: AppColors.energy, weight: FontWeight.w800)),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text('$days', style: AppTypography.display(40, color: AppColors.ink)),
            const SizedBox(width: 4),
            Text('days', style: AppTypography.ui(14, color: AppColors.ink3, weight: FontWeight.w700)),
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            for (var i = 0; i < 5; i++) ...[
              Expanded(
                child: Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: i < lit ? AppColors.energy : AppColors.energy.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              if (i < 4) const SizedBox(width: 4),
            ],
          ]),
          const SizedBox(height: AppSpacing.md),
          Row(children: [
            const Icon(Icons.shield_rounded, color: AppColors.energy, size: 14),
            const SizedBox(width: 4),
            Text('$shields shields ready', style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w600)),
          ]),
        ],
      ),
    );
  }
}

/// Rank card — blue, points + progress to next rank (FR-4.3).
class RankCard extends StatelessWidget {
  const RankCard({super.key, required this.rank, required this.points, required this.pointsToNext});
  final Rank rank;
  final int points;
  final int pointsToNext;

  @override
  Widget build(BuildContext context) {
    final next = rank.next;
    final span = next == null ? 1 : (next.threshold - rank.threshold);
    final progress = next == null ? 1.0 : ((points - rank.threshold) / span).clamp(0.0, 1.0);
    return BentoCard(
      color: AppColors.primarySoft,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.emoji_events_rounded, color: AppColors.primaryDeep, size: 16),
            const SizedBox(width: 6),
            Text('RANK', style: AppTypography.ui(11, color: AppColors.primaryDeep, weight: FontWeight.w800)),
          ]),
          const SizedBox(height: AppSpacing.md),
          Text(rank.label, style: AppTypography.display(28, color: AppColors.primaryDeep)),
          Text('$points pts', style: AppTypography.mono(13, color: AppColors.ink2)),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            next == null ? 'Max rank reached' : '$pointsToNext pts to ${next.label}',
            style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

/// Mood check-in (FR-4.4 / FR-9).
class MoodPicker extends StatelessWidget {
  const MoodPicker({super.key, required this.selected, required this.onSelect});
  final Mood selected;
  final ValueChanged<Mood> onSelect;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('How are you feeling?', style: AppTypography.ui(17, weight: FontWeight.w800)),
                  Text("I'll tailor your session.", style: AppTypography.ui(13, color: AppColors.ink3, weight: FontWeight.w500)),
                ],
              ),
            ),
            TakoMascot(size: 40, mood: selected),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              for (final m in Mood.values) ...[
                Expanded(child: _MoodChip(mood: m, selected: m == selected, onTap: () => onSelect(m))),
                if (m != Mood.values.last) const SizedBox(width: AppSpacing.sm),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MoodChip extends StatelessWidget {
  const _MoodChip({required this.mood, required this.selected, required this.onTap});
  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadii.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.primarySoft : AppColors.surface,
          borderRadius: AppRadii.cardRadius,
          border: Border.all(color: selected ? AppColors.primary : AppColors.line, width: selected ? 1.6 : 1),
        ),
        child: Column(
          children: [
            Text(mood.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              mood.label,
              textAlign: TextAlign.center,
              style: AppTypography.ui(11, color: selected ? AppColors.primaryDeep : AppColors.ink3, weight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Next up" hero CTA — the gulf-of-execution shortcut (FR-4.5 / SRS §8).
class NextUpCard extends StatelessWidget {
  const NextUpCard({super.key, required this.task, required this.onStart, required this.onSkip});
  final TaskItem? task;
  final VoidCallback onStart;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    if (task == null) {
      return BentoCard(
        gradient: AppColors.primaryGradient,
        child: Row(children: [
          const Icon(Icons.celebration_rounded, color: Colors.white, size: 28),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text('All done for today! 🎉',
                style: AppTypography.display(20, color: Colors.white)),
          ),
        ]),
      );
    }
    final t = task!;
    return BentoCard(
      gradient: AppColors.primaryGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.bolt_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 4),
            Text('NEXT UP', style: AppTypography.ui(11, color: Colors.white, weight: FontWeight.w800)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          Text(t.title, style: AppTypography.display(22, color: Colors.white)),
          const SizedBox(height: AppSpacing.sm),
          Row(children: [
            const Icon(Icons.schedule_rounded, color: Colors.white70, size: 14),
            const SizedBox(width: 4),
            Text('${t.minutes} min', style: AppTypography.ui(12, color: Colors.white70, weight: FontWeight.w700)),
            const SizedBox(width: 10),
            Text('+${t.points} pts', style: AppTypography.mono(12, color: Colors.white)),
            const SizedBox(width: 10),
            Flexible(
              child: Text('· ${t.goal}',
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTypography.ui(12, color: Colors.white70, weight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: AppSpacing.lg),
          Row(children: [
            Expanded(
              child: Material(
                color: Colors.white,
                borderRadius: AppRadii.lgRadius,
                child: InkWell(
                  onTap: onStart,
                  borderRadius: AppRadii.lgRadius,
                  child: Container(
                    height: 50,
                    alignment: Alignment.center,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.play_arrow_rounded, color: AppColors.primaryDeep, size: 22),
                      const SizedBox(width: 4),
                      Text('Start now', style: AppTypography.ui(16, color: AppColors.primaryDeep, weight: FontWeight.w800)),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Material(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: AppRadii.lgRadius,
              child: InkWell(
                onTap: onSkip,
                borderRadius: AppRadii.lgRadius,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                  alignment: Alignment.center,
                  child: Text('Skip', style: AppTypography.ui(16, color: Colors.white, weight: FontWeight.w700)),
                ),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

/// A single task row with a completion checkbox (FR-4.6 / FR-4.7).
class TaskTile extends StatelessWidget {
  const TaskTile({super.key, required this.task, required this.onToggle});
  final TaskItem task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: onToggle,
      child: Row(children: [
        _Check(done: task.done),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.title,
                style: AppTypography.ui(15, weight: FontWeight.w700).copyWith(
                  decoration: task.done ? TextDecoration.lineThrough : null,
                  color: task.done ? AppColors.ink4 : AppColors.ink,
                ),
              ),
              const SizedBox(height: 2),
              Text('⏱ ${task.minutes}m · ${task.goal}',
                  style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w600)),
            ],
          ),
        ),
        Text('+${task.points}', style: AppTypography.mono(13, color: task.done ? AppColors.ink4 : AppColors.primaryDeep)),
      ]),
    );
  }
}

class _Check extends StatelessWidget {
  const _Check({required this.done});
  final bool done;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: done ? AppColors.mint : AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: done ? null : Border.all(color: AppColors.line2, width: 1.5),
      ),
      child: done ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
    );
  }
}
