import '../models/task_item.dart';

/// Today's task list boundary (SRS FR-4.6/4.7, FR-5.6).
abstract interface class TasksRepository {
  Future<List<TaskItem>> todayTasks();
  Future<void> setDone(String id, {required bool done});
  Future<void> addTasks(List<TaskItem> tasks);
}
