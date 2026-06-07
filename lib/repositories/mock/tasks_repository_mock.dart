import '../../models/task_item.dart';
import '../tasks_repository.dart';
import 'seed.dart';

/// In-memory mock of today's tasks; mutations persist for the session only.
class TasksRepositoryMock implements TasksRepository {
  TasksRepositoryMock() : _tasks = List.of(Seed.todayTasks());

  final List<TaskItem> _tasks;

  @override
  Future<List<TaskItem>> todayTasks() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_tasks);
  }

  @override
  Future<void> setDone(String id, {required bool done}) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i != -1) _tasks[i] = _tasks[i].copyWith(done: done);
  }

  @override
  Future<void> addTasks(List<TaskItem> tasks) async {
    _tasks.addAll(tasks);
  }
}
