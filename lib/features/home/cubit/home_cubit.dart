import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/app_user.dart';
import '../../../models/mood.dart';
import '../../../models/rank.dart';
import '../../../models/task_item.dart';
import '../../../repositories/gamification_repository.dart';
import '../../../repositories/tasks_repository.dart';

part 'home_state.dart';

/// Home/Dashboard state (SRS FR-4) + the gamification feedback loop (FR-8):
/// completing a task awards points and can move the user up a rank.
class HomeCubit extends Cubit<HomeState> {
  HomeCubit({required GamificationRepository gamification, required TasksRepository tasks})
      : _gamification = gamification,
        _tasks = tasks,
        super(const HomeState());

  final GamificationRepository _gamification;
  final TasksRepository _tasks;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final user = await _gamification.profile();
      final tasks = await _tasks.todayTasks();
      emit(state.copyWith(status: ViewStatus.success, user: user, tasks: tasks));
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }

  /// Toggle a task's completion, award/retract its points, and persist (FR-4.7).
  Future<void> toggleTask(String id) async {
    final user = state.user;
    final index = state.tasks.indexWhere((t) => t.id == id);
    if (user == null || index == -1) return;

    final task = state.tasks[index];
    final nowDone = !task.done;
    final tasks = List<TaskItem>.of(state.tasks)..[index] = task.copyWith(done: nowDone);
    final points = (user.points + (nowDone ? task.points : -task.points)).clamp(0, 1 << 30);

    emit(state.copyWith(tasks: tasks, user: user.copyWith(points: points)));
    await _tasks.setDone(id, done: nowDone);
  }

  /// Record a mood check-in (SRS FR-4.4 / FR-9).
  void setMood(Mood mood) {
    final user = state.user;
    if (user == null) return;
    emit(state.copyWith(user: user.copyWith(mood: mood)));
  }

  /// True when the last [toggleTask] pushed the user into a new rank — the UI
  /// can use this to celebrate (FR-8.2). Computed from before/after points.
  static bool didRankUp(int before, int after) =>
      Rank.forPoints(after).index > Rank.forPoints(before).index;
}
