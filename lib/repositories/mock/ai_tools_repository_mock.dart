import '../../models/day_block.dart';
import '../../models/mood.dart';
import '../../models/quiz_question.dart';
import '../../models/task_item.dart';
import '../ai_tools_repository.dart';

class AiToolsRepositoryMock implements AiToolsRepository {
  @override
  Future<List<QuizQuestion>> generateQuiz({
    required String topic,
    int count = 5,
    String difficulty = 'medium',
  }) async =>
      [
        QuizQuestion(question: 'Sample question about $topic?', options: const ['Option A', 'Option B', 'Option C', 'Option D'], answerIndex: 0),
        const QuizQuestion(question: 'Another sample question?', options: ['True', 'False', 'Maybe', 'Unknown'], answerIndex: 1),
        const QuizQuestion(question: 'A final sample question?', options: ['1', '2', '3', '4'], answerIndex: 2),
      ];

  @override
  Future<List<DayBlock>> planDay({
    required List<TaskItem> tasks,
    required int availableMinutes,
    required Mood mood,
  }) async =>
      const [
        DayBlock(start: '09:00', end: '09:25', taskTitle: 'Focus block'),
        DayBlock(start: '09:25', end: '09:30', taskTitle: 'Break'),
        DayBlock(start: '09:30', end: '09:55', taskTitle: 'Focus block'),
      ];
}
