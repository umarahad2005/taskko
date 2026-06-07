import '../../models/focus_session.dart';
import '../../models/mood.dart';
import '../session_repository.dart';

class SessionRepositoryMock implements SessionRepository {
  final List<FocusSession> _sessions = [];

  @override
  Future<void> logSession({
    required String taskTitle,
    required int minutes,
    required Mood mood,
    int? rating,
  }) async {
    _sessions.insert(
      0,
      FocusSession(
        id: 's${_sessions.length}',
        taskTitle: taskTitle,
        minutes: minutes,
        mood: mood,
        startedAt: DateTime.now(),
        rating: rating,
      ),
    );
  }

  @override
  Future<List<FocusSession>> recent({int limit = 60}) async =>
      List.unmodifiable(_sessions.take(limit));
}
