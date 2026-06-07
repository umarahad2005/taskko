import '../models/clarify_question.dart';
import '../models/plan_task.dart';

/// AI Plan Studio boundary (SRS FR-5). The mock returns scripted data; the real
/// impl calls `POST /api/ai/clarify` + `POST /api/ai/breakdown` (Gemini).
abstract interface class PlanRepository {
  /// Ask Tako for clarifying questions about a goal (empty if already specific).
  Future<List<ClarifyQuestion>> clarify(String goal);

  /// Break a (possibly enriched) goal into an ordered list of tasks.
  Future<List<PlanTask>> breakdown(String goal);
}
