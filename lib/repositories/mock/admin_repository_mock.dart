import '../../models/admin_metrics.dart';
import '../../models/admin_user.dart';
import '../admin_repository.dart';

/// In-memory admin console (offline demos / widget tests). Mirrors the shape of
/// the real `/api/admin/*` responses with a small sample dataset.
class AdminRepositoryMock implements AdminRepository {
  final List<AdminUser> _users = [
    const AdminUser(id: 'u1', name: 'Aisha Khan', email: 'aisha@taskko.app', plan: 'free', rank: 'Pro', points: 1240, status: 'active'),
    const AdminUser(id: 'u2', name: 'Bilal Ahmed', email: 'bilal@taskko.app', plan: 'free', rank: 'Rookie', points: 320, status: 'flagged'),
    const AdminUser(id: 'u3', name: 'Sara Malik', email: 'sara@taskko.app', plan: 'free', rank: 'Elite', points: 1680, status: 'active'),
    const AdminUser(id: 'u4', name: 'Demo Student', email: 'demo@taskko.app', plan: 'free', rank: 'Rookie', points: 80, status: 'suspended'),
  ];

  @override
  Future<AdminMetrics> metrics() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const AdminMetrics(
      dau: 3,
      signupsToday: 1,
      activeStreaks: 2,
      aiCallsToday: 14,
      avgTasksPerUser: 4.2,
      rankDistribution: [RankCount('Rookie', 2), RankCount('Pro', 1), RankCount('Elite', 1), RankCount('Legend', 0)],
      topGoals: [TopGoal('Prepare MAD quiz', 2), TopGoal('Finish OS assignment', 1)],
      activityFeed: [ActivityItem('Demo Student joined', ''), ActivityItem('Aisha Khan joined', '')],
    );
  }

  @override
  Future<List<AdminUser>> users({String filter = 'all', String query = ''}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    var out = _users.toList();
    if (filter != 'all') out = out.where((u) => u.plan == filter || u.status == filter).toList();
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      out = out.where((u) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q)).toList();
    }
    return out;
  }

  @override
  Future<AdminUser> userAction({required String userId, required String action, int? points}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final i = _users.indexWhere((u) => u.id == userId);
    if (i == -1) throw StateError('No such user');
    final u = _users[i];
    final updated = AdminUser(
      id: u.id,
      name: u.name,
      email: u.email,
      plan: u.plan,
      rank: u.rank,
      points: action == 'grant_points' ? u.points + (points ?? 0) : u.points,
      status: action == 'suspend' ? 'suspended' : action == 'reinstate' ? 'active' : u.status,
    );
    _users[i] = updated;
    return updated;
  }
}
