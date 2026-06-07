import 'package:equatable/equatable.dart';

/// A task proposed by the AI Plan Studio before it is committed (SRS FR-5).
class PlanTask extends Equatable {
  const PlanTask({
    required this.id,
    required this.title,
    required this.minutes,
    required this.points,
  });

  final String id;
  final String title;
  final int minutes;
  final int points;

  PlanTask copyWith({String? title, int? minutes, int? points}) => PlanTask(
        id: id,
        title: title ?? this.title,
        minutes: minutes ?? this.minutes,
        points: points ?? this.points,
      );

  @override
  List<Object?> get props => [id, title, minutes, points];
}
