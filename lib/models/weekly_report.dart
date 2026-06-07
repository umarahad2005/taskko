import 'package:equatable/equatable.dart';

/// A shareable weekly summary (SRS FR-6.5).
class WeeklyReport extends Equatable {
  const WeeklyReport({
    required this.tasksDone,
    required this.points,
    required this.focusMinutes,
    required this.streakDays,
    required this.topGoal,
  });

  final int tasksDone;
  final int points;
  final int focusMinutes;
  final int streakDays;
  final String topGoal;

  /// Plain-text version used for social sharing (FR-6.6).
  String get shareText =>
      'My Taskko week 📚\n'
      '✅ $tasksDone tasks done\n'
      '⭐ $points points\n'
      '⏱ ${focusMinutes ~/ 60}h ${focusMinutes % 60}m focused\n'
      '🔥 $streakDays-day streak\n'
      'Top goal: $topGoal';

  @override
  List<Object?> get props => [tasksDone, points, focusMinutes, streakDays, topGoal];
}
