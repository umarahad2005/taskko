part of 'plan_cubit.dart';

/// The three steps of the Plan Studio flow (SRS FR-5.1).
enum PlanStep { input, generating, review }

class PlanState extends Equatable {
  const PlanState({
    this.step = PlanStep.input,
    this.goal = '',
    this.tasks = const [],
    this.error,
    this.committed = false,
  });

  final PlanStep step;
  final String goal;
  final List<PlanTask> tasks;
  final String? error;
  final bool committed;

  int get totalMinutes => tasks.fold(0, (sum, t) => sum + t.minutes);
  int get totalPoints => tasks.fold(0, (sum, t) => sum + t.points);

  PlanState copyWith({
    PlanStep? step,
    String? goal,
    List<PlanTask>? tasks,
    String? error,
    bool? committed,
  }) =>
      PlanState(
        step: step ?? this.step,
        goal: goal ?? this.goal,
        tasks: tasks ?? this.tasks,
        error: error,
        committed: committed ?? this.committed,
      );

  @override
  List<Object?> get props => [step, goal, tasks, error, committed];
}
