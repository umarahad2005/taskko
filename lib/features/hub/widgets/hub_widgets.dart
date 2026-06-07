import 'package:flutter/material.dart';

import '../../../models/badge_item.dart';
import '../../../models/leaderboard_entry.dart';
import '../../../models/weekly_report.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_radii.dart';
import '../../../theme/app_typography.dart';
import '../../../widgets/bento_card.dart';
import '../cubit/hub_cubit.dart';

const _badgePalette = [
  AppColors.energy,
  AppColors.primary,
  AppColors.gold,
  AppColors.mint,
  AppColors.rose,
  AppColors.lavender,
  AppColors.primaryDeep,
];

/// Segmented tab selector: Badges · Squad · Report card (SRS FR-6.1).
class HubTabs extends StatelessWidget {
  const HubTabs({super.key, required this.selected, required this.onSelect});
  final HubTab selected;
  final ValueChanged<HubTab> onSelect;

  static const _labels = {HubTab.badges: 'Badges', HubTab.squad: 'Squad', HubTab.report: 'Report card'};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadii.pillRadius),
      child: Row(
        children: [
          for (final tab in HubTab.values)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelect(tab),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tab == selected ? AppColors.ink : Colors.transparent,
                    borderRadius: AppRadii.pillRadius,
                  ),
                  child: Text(
                    _labels[tab]!,
                    style: AppTypography.ui(13,
                        color: tab == selected ? Colors.white : AppColors.ink3, weight: FontWeight.w700),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Highlight card for the most recently unlocked badge (SRS FR-6.2).
class NewBadgeCard extends StatelessWidget {
  const NewBadgeCard({super.key, required this.badge, required this.onShare, required this.onView});
  final BadgeItem badge;
  final VoidCallback onShare;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      color: AppColors.energySoft,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('NEW BADGE!', style: AppTypography.ui(11, color: AppColors.energy, weight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(badge.title, style: AppTypography.display(22)),
                Text('Unlocked this morning', style: AppTypography.ui(12, color: AppColors.ink3, weight: FontWeight.w500)),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  _MiniBtn(label: 'Share', icon: Icons.ios_share_rounded, filled: true, onTap: onShare),
                  const SizedBox(width: AppSpacing.sm),
                  _MiniBtn(label: 'View', onTap: onView),
                ]),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          _BadgeMedallion(emoji: badge.emoji, color: AppColors.energy, size: 64),
        ],
      ),
    );
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.label, required this.onTap, this.icon, this.filled = false});
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: filled ? AppColors.energy : AppColors.surface,
      borderRadius: AppRadii.pillRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadii.pillRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 9),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: filled ? Colors.white : AppColors.ink2),
              const SizedBox(width: 4),
            ],
            Text(label, style: AppTypography.ui(13, color: filled ? Colors.white : AppColors.ink2, weight: FontWeight.w700)),
          ]),
        ),
      ),
    );
  }
}

class _BadgeMedallion extends StatelessWidget {
  const _BadgeMedallion({required this.emoji, required this.color, this.size = 56, this.locked = false});
  final String emoji;
  final Color color;
  final double size;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: locked
            ? null
            : LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [color.withValues(alpha: 0.85), color]),
        color: locked ? AppColors.line : null,
        shape: BoxShape.circle,
        boxShadow: locked ? null : [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: locked
          ? const Icon(Icons.lock_rounded, color: AppColors.ink4, size: 20)
          : Text(emoji, style: TextStyle(fontSize: size * 0.42)),
    );
  }
}

/// Badge in the grid — colored when unlocked, greyed + locked otherwise (FR-6.3).
class BadgeTile extends StatelessWidget {
  const BadgeTile({super.key, required this.badge, required this.index});
  final BadgeItem badge;
  final int index;

  @override
  Widget build(BuildContext context) {
    final color = _badgePalette[index % _badgePalette.length];
    return BentoCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BadgeMedallion(emoji: badge.emoji, color: color, size: 52, locked: !badge.unlocked),
          const SizedBox(height: AppSpacing.sm),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.ui(12,
                color: badge.unlocked ? AppColors.ink : AppColors.ink4, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

/// Squad leaderboard list with the current user highlighted (SRS FR-6.4).
class LeaderboardList extends StatelessWidget {
  const LeaderboardList({super.key, required this.entries});
  final List<LeaderboardEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final e in entries) ...[
          _LeaderRow(entry: e),
          const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _LeaderRow extends StatelessWidget {
  const _LeaderRow({required this.entry});
  final LeaderboardEntry entry;

  Color get _medal => switch (entry.position) {
        1 => AppColors.gold,
        2 => AppColors.ink4,
        3 => AppColors.energy,
        _ => AppColors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return BentoCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      color: entry.isYou ? AppColors.primarySoft : AppColors.surface,
      child: Row(children: [
        SizedBox(
          width: 26,
          child: Text('${entry.position}',
              textAlign: TextAlign.center, style: AppTypography.ui(15, color: AppColors.ink3, weight: FontWeight.w800)),
        ),
        const SizedBox(width: AppSpacing.sm),
        CircleAvatar(
          radius: 16,
          backgroundColor: _medal,
          child: Text(entry.name.isNotEmpty ? entry.name[0] : '?',
              style: AppTypography.ui(13, color: Colors.white, weight: FontWeight.w800)),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Text(entry.name,
              style: AppTypography.ui(15, weight: FontWeight.w700, color: entry.isYou ? AppColors.primaryDeep : AppColors.ink)),
        ),
        Text('${entry.points} pts', style: AppTypography.mono(13, color: AppColors.ink2)),
      ]),
    );
  }
}

/// Shareable weekly report card (SRS FR-6.5 / FR-6.6).
class ReportCardView extends StatelessWidget {
  const ReportCardView({super.key, required this.report, required this.onShare});
  final WeeklyReport report;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BentoCard(
          gradient: AppColors.primaryGradient,
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('THIS WEEK', style: AppTypography.ui(11, color: Colors.white70, weight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('Your report card', style: AppTypography.display(24, color: Colors.white)),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                _Stat(value: '${report.tasksDone}', label: 'tasks done'),
                _Stat(value: '${report.points}', label: 'points'),
                _Stat(value: '${report.streakDays}d', label: 'streak'),
              ]),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                _Stat(value: '${report.focusMinutes ~/ 60}h ${report.focusMinutes % 60}m', label: 'focused'),
                _Stat(value: report.topGoal, label: 'top goal', flexible: true),
              ]),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Material(
          color: AppColors.energy,
          borderRadius: AppRadii.lgRadius,
          child: InkWell(
            onTap: onShare,
            borderRadius: AppRadii.lgRadius,
            child: Container(
              height: 54,
              alignment: Alignment.center,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.ios_share_rounded, color: Colors.white, size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text('Share my week', style: AppTypography.ui(16, color: Colors.white, weight: FontWeight.w800)),
              ]),
            ),
          ),
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.flexible = false});
  final String value;
  final String label;
  final bool flexible;

  @override
  Widget build(BuildContext context) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.display(20, color: Colors.white)),
        Text(label, style: AppTypography.ui(11, color: Colors.white70, weight: FontWeight.w600)),
      ],
    );
    return flexible ? Expanded(child: content) : Expanded(child: content);
  }
}
