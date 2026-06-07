import 'package:equatable/equatable.dart';

/// A time block in an AI-generated day plan (M13).
class DayBlock extends Equatable {
  const DayBlock({required this.start, required this.end, required this.taskTitle});

  final String start;
  final String end;
  final String taskTitle;

  bool get isBreak => taskTitle.trim().toLowerCase() == 'break';

  @override
  List<Object?> get props => [start, end, taskTitle];
}
