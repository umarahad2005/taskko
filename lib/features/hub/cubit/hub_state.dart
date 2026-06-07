part of 'hub_cubit.dart';

enum HubTab { badges, squad, report }

class HubState extends Equatable {
  const HubState({
    this.status = ViewStatus.initial,
    this.tab = HubTab.badges,
    this.badges = const [],
    this.leaderboard = const [],
    this.report,
  });

  final ViewStatus status;
  final HubTab tab;
  final List<BadgeItem> badges;
  final List<LeaderboardEntry> leaderboard;
  final WeeklyReport? report;

  int get unlockedCount => badges.where((b) => b.unlocked).length;
  BadgeItem? get latestBadge {
    for (final b in badges) {
      if (b.unlocked) return b;
    }
    return null;
  }

  HubState copyWith({
    ViewStatus? status,
    HubTab? tab,
    List<BadgeItem>? badges,
    List<LeaderboardEntry>? leaderboard,
    WeeklyReport? report,
  }) =>
      HubState(
        status: status ?? this.status,
        tab: tab ?? this.tab,
        badges: badges ?? this.badges,
        leaderboard: leaderboard ?? this.leaderboard,
        report: report ?? this.report,
      );

  @override
  List<Object?> get props => [status, tab, badges, leaderboard, report];
}
