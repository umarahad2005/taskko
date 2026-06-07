import 'package:equatable/equatable.dart';

import 'mood.dart';

/// A completed focus session (SRS FR-10.3), stored at `users/{uid}/sessions/{id}`.
class FocusSession extends Equatable {
  const FocusSession({
    required this.id,
    required this.taskTitle,
    required this.minutes,
    required this.mood,
    required this.startedAt,
    this.rating,
  });

  final String id;
  final String taskTitle;
  final int minutes;
  final Mood mood;
  final DateTime startedAt;

  /// Post-task reflection 1–3 (😫/😐/😀), null if skipped (FR-10.2).
  final int? rating;

  @override
  List<Object?> get props => [id, taskTitle, minutes, mood, startedAt, rating];
}
