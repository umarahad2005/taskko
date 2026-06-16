/// Dashboard KPIs + aggregates for the admin console (FR-11.3).
/// Mirrors the `/api/admin/metrics` response.
class AdminMetrics {
  const AdminMetrics({
    required this.dau,
    required this.signupsToday,
    required this.activeStreaks,
    required this.aiCallsToday,
    required this.avgTasksPerUser,
    required this.rankDistribution,
    required this.topGoals,
    required this.activityFeed,
  });

  final int dau;
  final int signupsToday;
  final int activeStreaks;
  final int aiCallsToday;
  final double avgTasksPerUser;
  final List<RankCount> rankDistribution;
  final List<TopGoal> topGoals;
  final List<ActivityItem> activityFeed;

  factory AdminMetrics.fromJson(Map<String, dynamic> j) {
    final kpis = (j['kpis'] as Map?)?.cast<String, dynamic>() ?? const {};
    List<T> list<T>(String key, T Function(Map<String, dynamic>) f) =>
        ((j[key] as List?) ?? const [])
            .whereType<Map>()
            .map((m) => f(m.cast<String, dynamic>()))
            .toList();
    return AdminMetrics(
      dau: (kpis['dau'] as num?)?.toInt() ?? 0,
      signupsToday: (kpis['signupsToday'] as num?)?.toInt() ?? 0,
      activeStreaks: (kpis['activeStreaks'] as num?)?.toInt() ?? 0,
      aiCallsToday: (kpis['aiCallsToday'] as num?)?.toInt() ?? 0,
      avgTasksPerUser: (kpis['avgTasksPerUser'] as num?)?.toDouble() ?? 0,
      rankDistribution: list('rankDistribution',
          (m) => RankCount((m['rank'] as String?) ?? '—', (m['count'] as num?)?.toInt() ?? 0)),
      topGoals: list('topGoals',
          (m) => TopGoal((m['goal'] as String?) ?? '—', (m['users'] as num?)?.toInt() ?? 0)),
      activityFeed: list('activityFeed',
          (m) => ActivityItem((m['text'] as String?) ?? '', (m['at'] as String?) ?? '')),
    );
  }
}

class RankCount {
  const RankCount(this.rank, this.count);
  final String rank;
  final int count;
}

class TopGoal {
  const TopGoal(this.goal, this.users);
  final String goal;
  final int users;
}

class ActivityItem {
  const ActivityItem(this.text, this.at);
  final String text;
  final String at;
}
