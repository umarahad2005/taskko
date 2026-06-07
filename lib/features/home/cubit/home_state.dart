part of 'home_cubit.dart';

class HomeState extends Equatable {
  const HomeState({
    this.status = ViewStatus.initial,
    this.user,
    this.tasks = const [],
  });

  final ViewStatus status;
  final AppUser? user;
  final List<TaskItem> tasks;

  int get total => tasks.length;
  int get doneCount => tasks.where((t) => t.done).length;
  int get remaining => total - doneCount;
  double get percent => total == 0 ? 0 : doneCount / total;

  /// The next actionable task = first not-done task (SRS FR-4.5).
  TaskItem? get nextTask {
    for (final t in tasks) {
      if (!t.done) return t;
    }
    return null;
  }

  HomeState copyWith({ViewStatus? status, AppUser? user, List<TaskItem>? tasks}) => HomeState(
        status: status ?? this.status,
        user: user ?? this.user,
        tasks: tasks ?? this.tasks,
      );

  @override
  List<Object?> get props => [status, user, tasks];
}
