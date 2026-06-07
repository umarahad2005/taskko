import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/clarify_question.dart';
import '../../../models/plan_task.dart';
import '../../../models/task_item.dart';
import '../../../repositories/plan_repository.dart';
import '../../../repositories/tasks_repository.dart';

part 'plan_state.dart';

/// AI Plan Studio (SRS FR-5): goal → (Tako clarifies) → AI breakdown → editable
/// plan → commit. Depends only on repository interfaces; real impls call the
/// backend (Gemini), mock impls are scripted. Clarification degrades gracefully
/// (if unavailable it goes straight to breakdown).
class PlanCubit extends Cubit<PlanState> {
  PlanCubit({required PlanRepository plan, required TasksRepository tasks})
      : _plan = plan,
        _tasks = tasks,
        super(const PlanState());

  final PlanRepository _plan;
  final TasksRepository _tasks;

  String _breakdownGoal = '';

  void updateGoal(String value) => emit(state.copyWith(goal: value));

  /// Step 1: from the goal, first try to get clarifying questions; if Tako has
  /// any, show them, otherwise break the goal down directly (FR-5.2/5.3).
  Future<void> generate() async {
    final goal = state.goal.trim();
    if (goal.length < 3) {
      emit(state.copyWith(error: 'Add a bit more detail to your goal'));
      return;
    }
    emit(state.copyWith(step: PlanStep.generating, error: null));
    final questions = await _plan.clarify(goal);
    if (questions.isNotEmpty) {
      emit(state.copyWith(step: PlanStep.clarify, questions: questions, answers: const {}));
      return;
    }
    await _runBreakdown(goal);
  }

  /// Record an answer to a clarifying question.
  void answerQuestion(String question, String answer) {
    final answers = Map<String, String>.of(state.answers)..[question] = answer;
    emit(state.copyWith(answers: answers));
  }

  /// Proceed from clarify → breakdown, enriching the goal with the answers.
  Future<void> submitClarify() {
    final buffer = StringBuffer(state.goal.trim());
    if (state.answers.isNotEmpty) {
      buffer.write('\nDetails:');
      state.answers.forEach((q, a) => buffer.write(' $q $a;'));
    }
    return _runBreakdown(buffer.toString());
  }

  /// Skip clarification and break the original goal down.
  Future<void> skipClarify() => _runBreakdown(state.goal.trim());

  /// Regenerate the plan from the same (enriched) goal — does not re-ask.
  Future<void> regenerate() =>
      _runBreakdown(_breakdownGoal.isEmpty ? state.goal.trim() : _breakdownGoal);

  Future<void> _runBreakdown(String text) async {
    _breakdownGoal = text;
    emit(state.copyWith(step: PlanStep.generating, error: null));
    try {
      final tasks = await _plan.breakdown(text);
      emit(state.copyWith(step: PlanStep.review, tasks: tasks));
    } catch (_) {
      emit(state.copyWith(step: PlanStep.input, error: "Tako couldn't generate a plan. Try again."));
    }
  }

  void editTask(String id, {String? title, int? minutes, int? points}) {
    final tasks = state.tasks
        .map((t) => t.id == id ? t.copyWith(title: title, minutes: minutes, points: points) : t)
        .toList();
    emit(state.copyWith(tasks: tasks));
  }

  void deleteTask(String id) =>
      emit(state.copyWith(tasks: state.tasks.where((t) => t.id != id).toList()));

  void addTask() {
    final id = 'p${DateTime.now().microsecondsSinceEpoch}';
    final tasks = List<PlanTask>.of(state.tasks)
      ..add(PlanTask(id: id, title: 'New task', minutes: 20, points: 20));
    emit(state.copyWith(tasks: tasks));
  }

  /// Commit the reviewed plan into today's task list (FR-5.6).
  Future<void> commit() async {
    final items = state.tasks
        .map((p) => TaskItem(id: p.id, title: p.title, minutes: p.minutes, points: p.points, goal: state.goal.trim()))
        .toList();
    await _tasks.addTasks(items);
    emit(state.copyWith(committed: true));
  }

  void reset() => emit(const PlanState());
}
