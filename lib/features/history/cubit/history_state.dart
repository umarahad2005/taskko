part of 'history_cubit.dart';

class HistoryState extends Equatable {
  const HistoryState({this.status = ViewStatus.initial, this.sessions = const []});

  final ViewStatus status;
  final List<FocusSession> sessions;

  int get totalMinutes => sessions.fold(0, (sum, s) => sum + s.minutes);
  int get sessionCount => sessions.length;

  /// Focus minutes for each of the last 7 days, oldest → today.
  List<int> get last7Minutes {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(7, (i) {
      final day = today.subtract(Duration(days: 6 - i));
      return sessions
          .where((s) {
            final d = DateTime(s.startedAt.year, s.startedAt.month, s.startedAt.day);
            return d == day;
          })
          .fold<int>(0, (sum, s) => sum + s.minutes);
    });
  }

  HistoryState copyWith({ViewStatus? status, List<FocusSession>? sessions}) =>
      HistoryState(status: status ?? this.status, sessions: sessions ?? this.sessions);

  @override
  List<Object?> get props => [status, sessions];
}
