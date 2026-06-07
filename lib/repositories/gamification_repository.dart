import '../models/app_user.dart';
import '../models/badge_item.dart';
import '../models/leaderboard_entry.dart';
import '../models/weekly_report.dart';

/// Profile + gamification boundary: points, rank, streak, badges, squad
/// leaderboard, and the weekly report (SRS FR-6, FR-8).
abstract interface class GamificationRepository {
  Future<AppUser> profile();
  Future<List<BadgeItem>> badges();
  Future<List<LeaderboardEntry>> leaderboard();
  Future<WeeklyReport> weeklyReport();
}
