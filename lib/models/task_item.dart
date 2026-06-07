import 'package:equatable/equatable.dart';

/// A single actionable task (SRS §7.1 `users/{uid}/tasks/{id}`).
class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.title,
    required this.minutes,
    required this.points,
    required this.goal,
    this.done = false,
  });

  final String id;
  final String title;
  final int minutes;
  final int points;
  final String goal;
  final bool done;

  TaskItem copyWith({bool? done}) => TaskItem(
        id: id,
        title: title,
        minutes: minutes,
        points: points,
        goal: goal,
        done: done ?? this.done,
      );

  @override
  List<Object?> get props => [id, title, minutes, points, goal, done];
}
