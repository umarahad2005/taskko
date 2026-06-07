import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/plan_task.dart';
import '../../../models/task_item.dart';
import '../../../repositories/plan_repository.dart';
import '../../../repositories/tasks_repository.dart';

part 'plan_state.dart';

/// AI Plan Studio (SRS FR-5): goal → AI breakdown → editable plan → commit.
/// Depends only on repository interfaces; the mock breakdown is swapped for the
/// real `/api/ai/breakdown` (Gemini) impl in M9 with no UI change.
class PlanCubit extends Cubit<PlanState> {
  PlanCubit({required PlanRepository plan, required TasksRepository tasks})
      : _plan = plan,
        _tasks = tasks,
        super(const PlanState());

  final PlanRepository _plan;
  final TasksRepository _tasks;

  void updateGoal(String value) => emit(state.copyWith(goal: value));

  /// Generate (or regenerate) the plan from the current goal (FR-5.3/5.4/5.5).
  Future<void> generate() async {
    if (state.goal.trim().length < 3) {
      emit(state.copyWith(error: 'Add a bit more detail to your goal'));
      return;
    }
    emit(state.copyWith(step: PlanStep.generating, error: null));
    try {
      final tasks = await _plan.breakdown(state.goal.trim());
      emit(state.copyWith(step: PlanStep.review, tasks: tasks));
    } catch (_) {
      // Stay on input with a retryable error so the flow never breaks (FR-5.4).
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

  /// Start a fresh plan.
  void reset() => emit(const PlanState());
}
