import '../models/focus_session.dart';
import '../models/mood.dart';

/// Focus-session history boundary (SRS FR-10.2/10.3).
abstract interface class SessionRepository {
  Future<void> logSession({
    required String taskTitle,
    required int minutes,
    required Mood mood,
    int? rating,
  });

  /// Most recent sessions (newest first), used for the history/stats screen.
  Future<List<FocusSession>> recent({int limit = 60});
}
