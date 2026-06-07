part of 'plan_cubit.dart';

/// Steps of the Plan Studio flow (SRS FR-5.1): goal → (clarify) → generate → review.
enum PlanStep { input, clarify, generating, review }

class PlanState extends Equatable {
  const PlanState({
    this.step = PlanStep.input,
    this.goal = '',
    this.tasks = const [],
    this.questions = const [],
    this.answers = const {},
    this.error,
    this.committed = false,
  });

  final PlanStep step;
  final String goal;
  final List<PlanTask> tasks;
  final List<ClarifyQuestion> questions;
  final Map<String, String> answers;
  final String? error;
  final bool committed;

  int get totalMinutes => tasks.fold(0, (sum, t) => sum + t.minutes);
  int get totalPoints => tasks.fold(0, (sum, t) => sum + t.points);
  bool get allAnswered => questions.every((q) => answers.containsKey(q.question));

  PlanState copyWith({
    PlanStep? step,
    String? goal,
    List<PlanTask>? tasks,
    List<ClarifyQuestion>? questions,
    Map<String, String>? answers,
    String? error,
    bool? committed,
  }) =>
      PlanState(
        step: step ?? this.step,
        goal: goal ?? this.goal,
        tasks: tasks ?? this.tasks,
        questions: questions ?? this.questions,
        answers: answers ?? this.answers,
        error: error,
        committed: committed ?? this.committed,
      );

  @override
  List<Object?> get props => [step, goal, tasks, questions, answers, error, committed];
}
