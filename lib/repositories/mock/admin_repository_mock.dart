import '../../models/admin_metrics.dart';
import '../../models/admin_settings.dart';
import '../../models/admin_user.dart';
import '../../models/ai_insights.dart';
import '../../models/moderation_item.dart';
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

  final List<ModerationItem> _moderation = [
    const ModerationItem(id: 'm1', targetUser: 'bilal@taskko.app', reason: 'Reported chat message: profanity', severity: 'high', status: 'open', createdAt: '2026-06-21T09:12:00Z'),
    const ModerationItem(id: 'm2', targetUser: 'demo@taskko.app', reason: 'Spam goal titles', severity: 'medium', status: 'open', createdAt: '2026-06-20T14:05:00Z'),
    const ModerationItem(id: 'm3', targetUser: 'sara@taskko.app', reason: 'Possible self-harm phrase in journal', severity: 'high', status: 'open', createdAt: '2026-06-20T08:40:00Z'),
    const ModerationItem(id: 'm4', targetUser: 'aisha@taskko.app', reason: 'Off-topic Tako prompt', severity: 'low', status: 'dismissed', createdAt: '2026-06-19T17:22:00Z'),
  ];

  final Map<String, bool> _flags = {
    'aiBreakdownEnabled': true,
    'socialSharingEnabled': true,
    'moodCheckInEnabled': true,
    'squadLeaderboardEnabled': true,
    'maintenanceMode': false,
  };

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

  @override
  Future<AdminUser> createUser({
    required String name,
    required String email,
    required String password,
    int points = 0,
    String plan = 'free',
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    final cleanEmail = email.trim().toLowerCase();
    if (_users.any((u) => u.email.toLowerCase() == cleanEmail)) {
      throw StateError('That email is already in use');
    }
    final user = AdminUser(
      id: 'u-${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim().isEmpty ? cleanEmail.split('@').first : name.trim(),
      email: email.trim(),
      plan: plan == 'pro' ? 'pro' : 'free',
      rank: _rankForPoints(points),
      points: points,
      status: 'active',
    );
    _users.insert(0, user);
    return user;
  }

  @override
  Future<AdminUser> updateUser({
    required String userId,
    String? name,
    String? email,
    int? points,
    String? plan,
    String? status,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    final i = _users.indexWhere((u) => u.id == userId);
    if (i == -1) throw StateError('No such user');
    final u = _users[i];
    final pts = points ?? u.points;
    final updated = AdminUser(
      id: u.id,
      name: name?.trim().isNotEmpty == true ? name!.trim() : u.name,
      email: email?.trim().isNotEmpty == true ? email!.trim() : u.email,
      plan: plan ?? u.plan,
      rank: _rankForPoints(pts),
      points: pts,
      status: status ?? u.status,
    );
    _users[i] = updated;
    return updated;
  }

  @override
  Future<void> deleteUser(String userId) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _users.removeWhere((u) => u.id == userId);
  }

  String _rankForPoints(int p) {
    if (p >= 3000) return 'Legend';
    if (p >= 1560) return 'Elite';
    if (p >= 1000) return 'Pro';
    return 'Rookie';
  }

  @override
  Future<List<ModerationItem>> moderationQueue({String severity = 'all'}) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    var out = _moderation.toList();
    if (severity != 'all') out = out.where((m) => m.severity == severity).toList();
    return out;
  }

  @override
  Future<ModerationItem> moderationAction({required String itemId, required String action}) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final i = _moderation.indexWhere((m) => m.id == itemId);
    if (i == -1) throw StateError('No such moderation item');
    const statusFor = {'dismiss': 'dismissed', 'warn': 'warned', 'suspend': 'suspended'};
    final updated = _moderation[i].copyWith(status: statusFor[action] ?? _moderation[i].status);
    _moderation[i] = updated;
    return updated;
  }

  @override
  Future<AiInsights> aiInsights() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return const AiInsights(
      callsToday: 14,
      calls7d: 96,
      avgLatencyMs: 1280,
      fallbackRate: 0.04,
      costToday: 0,
      costMonth: 0,
      quality: [
        AiQuality(feature: 'plan-day', good: 0.95, fallback: 0.05),
        AiQuality(feature: 'chat', good: 0.92, fallback: 0.08),
        AiQuality(feature: 'quiz', good: 0.98, fallback: 0.02),
        AiQuality(feature: 'breakdown', good: 0.90, fallback: 0.10),
      ],
      stuckPhrases: ["I don't get recursion", 'how to start my essay', 'too much to study'],
      recentPrompts: [
        AiPrompt(feature: 'plan-day', goal: 'Prepare MAD quiz', at: '2m ago'),
        AiPrompt(feature: 'chat', message: 'Explain Big-O simply', at: '6m ago'),
        AiPrompt(feature: 'breakdown', goal: 'Finish OS assignment', at: '11m ago'),
        AiPrompt(feature: 'quiz', goal: 'Stats midterm', at: '18m ago'),
      ],
    );
  }

  @override
  Future<AdminSettings> settings() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return AdminSettings(
      flags: Map<String, bool>.from(_flags),
      adminTeam: const [
        AdminMember(email: 'admin@taskko.app', role: 'owner'),
      ],
    );
  }

  @override
  Future<AdminSettings> updateFlags(Map<String, bool> flags) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _flags.addAll(flags);
    return AdminSettings(
      flags: Map<String, bool>.from(_flags),
      adminTeam: const [
        AdminMember(email: 'admin@taskko.app', role: 'owner'),
      ],
    );
  }
}
