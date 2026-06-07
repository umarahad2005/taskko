import '../../models/app_user.dart';
import '../../models/badge_item.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/mood.dart';
import '../../models/weekly_report.dart';
import '../gamification_repository.dart';
import 'seed.dart';

class GamificationRepositoryMock implements GamificationRepository {
  @override
  Future<AppUser> profile() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Seed.user;
  }

  @override
  Future<AppUser> setMood(Mood mood) async => Seed.user.copyWith(mood: mood);

  @override
  Future<AppUser> recordTaskCompletion({required int points, required bool nowDone}) async =>
      Seed.user.copyWith(points: (Seed.user.points + (nowDone ? points : -points)).clamp(0, 1 << 30));

  @override
  Future<List<BadgeItem>> badges() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Seed.badges();
  }

  @override
  Future<List<LeaderboardEntry>> leaderboard() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Seed.leaderboard();
  }

  @override
  Future<WeeklyReport> weeklyReport() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Seed.weeklyReport();
  }
}
