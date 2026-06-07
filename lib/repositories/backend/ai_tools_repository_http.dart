import '../../models/day_block.dart';
import '../../models/mood.dart';
import '../../models/quiz_question.dart';
import '../../models/task_item.dart';
import '../ai_tools_repository.dart';
import 'ai_api_client.dart';

/// Real AI study tools — calls `/api/ai/quiz` + `/api/ai/plan-day` (Gemini).
class AiToolsRepositoryHttp implements AiToolsRepository {
  AiToolsRepositoryHttp(this._api);

  final AiApiClient _api;

  @override
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    int count = 5,
    String difficulty = 'medium',
  }) async {
    final json = await _api.postJson('/api/ai/quiz', {
      'topic': topic,
      'count': count,
      'difficulty': difficulty,
    });
    final raw = (json['questions'] as List?) ?? const [];
    final questions = raw
        .whereType<Map<String, dynamic>>()
        .map((m) => QuizQuestion(
              question: (m['q'] as String?) ?? '',
              options: ((m['options'] as List?) ?? const []).whereType<String>().toList(),
              answerIndex: (m['answerIndex'] as num?)?.toInt() ?? 0,
            ))
        .where((q) => q.question.isNotEmpty && q.options.length >= 2)
        .toList();
    if (questions.isEmpty) {
      throw AiApiException('Tako could not generate a quiz on that — try another topic.');
    }
    return questions;
  }

  @override
  Future<List<DayBlock>> planDay({
    required List<TaskItem> tasks,
    required int availableMinutes,
    required Mood mood,
  }) async {
    final json = await _api.postJson('/api/ai/plan-day', {
      'tasks': tasks.map((t) => {'title': t.title, 'minutes': t.minutes}).toList(),
      'availableMinutes': availableMinutes,
      'mood': mood.name,
    });
    final raw = (json['blocks'] as List?) ?? const [];
    return raw
        .whereType<Map<String, dynamic>>()
        .map((m) => DayBlock(
              start: (m['start'] as String?) ?? '',
              end: (m['end'] as String?) ?? '',
              taskTitle: (m['taskTitle'] as String?) ?? '',
            ))
        .where((b) => b.start.isNotEmpty && b.taskTitle.isNotEmpty)
        .toList();
  }
}
