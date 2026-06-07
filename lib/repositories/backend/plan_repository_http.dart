import '../../models/plan_task.dart';
import '../plan_repository.dart';
import 'ai_api_client.dart';

/// Real AI Plan Studio repository — calls the backend `/api/ai/breakdown`
/// (Gemini) instead of the scripted mock (SRS FR-5.3).
class PlanRepositoryHttp implements PlanRepository {
  PlanRepositoryHttp(this._api);

  final AiApiClient _api;

  @override
  Future<List<PlanTask>> breakdown(String goal) async {
    final json = await _api.postJson('/api/ai/breakdown', {'goal': goal});
    final raw = (json['tasks'] as List?) ?? const [];
    var i = 0;
    return raw.whereType<Map<String, dynamic>>().map((m) {
      return PlanTask(
        id: 'g${i++}',
        title: (m['title'] as String?)?.trim().isNotEmpty == true ? m['title'] as String : 'Task',
        minutes: (m['minutes'] as num?)?.toInt() ?? 20,
        points: (m['points'] as num?)?.toInt() ?? 20,
      );
    }).toList();
  }
}
