import '../models/day_block.dart';
import '../models/mood.dart';
import '../models/quiz_question.dart';
import '../models/task_item.dart';

/// AI study tools (M13): quiz generation + day planning. Real impl calls the
/// backend (`/api/ai/quiz`, `/api/ai/plan-day`); mock is scripted.
abstract interface class AiToolsRepository {
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    int count,
    String difficulty,
  });

  Future<List<DayBlock>> planDay({
    required List<TaskItem> tasks,
    required int availableMinutes,
    required Mood mood,
  });
}
