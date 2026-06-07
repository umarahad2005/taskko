import '../models/plan_task.dart';

/// AI Plan Studio boundary (SRS FR-5). The mock returns a scripted breakdown;
/// the real impl calls `POST /api/ai/breakdown` (Gemini) in M9.
abstract interface class PlanRepository {
  Future<List<PlanTask>> breakdown(String goal);
}
