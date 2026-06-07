import '../../models/plan_task.dart';
import '../plan_repository.dart';
import 'seed.dart';

/// Scripted "AI" breakdown with a realistic generation delay (SRS FR-5.3/5.4).
class PlanRepositoryMock implements PlanRepository {
  @override
  Future<List<PlanTask>> breakdown(String goal) async {
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (goal.trim().isEmpty) {
      throw ArgumentError('Goal cannot be empty');
    }
    return Seed.planReview();
  }
}
