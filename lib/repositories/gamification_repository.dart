import '../models/app_user.dart';
import '../models/badge_item.dart';
import '../models/leaderboard_entry.dart';
import '../models/mood.dart';
import '../models/weekly_report.dart';

/// Profile + gamification boundary: points, rank, streak, badges, squad
/// leaderboard, and the weekly report (SRS FR-6, FR-8).
abstract interface class GamificationRepository {
  /// Load (creating on first use) the signed-in user's profile.
  Future<AppUser> profile();

  /// Persist a mood check-in (FR-4.4 / FR-9) and return the updated profile.
  Future<AppUser> setMood(Mood mood);

  /// Apply a task completion/uncompletion: award/retract [points] and update
  /// the daily streak; returns the updated profile (FR-4.7 / FR-8).
  Future<AppUser> recordTaskCompletion({required int points, required bool nowDone});

  Future<List<BadgeItem>> badges();
  Future<List<LeaderboardEntry>> leaderboard();
  Future<WeeklyReport> weeklyReport();
}
