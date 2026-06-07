import '../../models/app_user.dart';
import '../../models/badge_item.dart';
import '../../models/chat_message.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/mood.dart';
import '../../models/plan_task.dart';
import '../../models/task_item.dart';
import '../../models/weekly_report.dart';

/// Seed data mirroring the approved prototype (`frameState` in capture-frames.html).
/// Used by every mock repository so the app demos believably without a backend.
abstract final class Seed {
  static const AppUser user = AppUser(
    id: 'demo-sara',
    name: 'Sara',
    email: 'sara@taskko.app',
    points: 1240,
    streakDays: 5,
    shields: 2,
    mood: Mood.focused,
  );

  static const AppUser admin = AppUser(
    id: 'demo-admin',
    name: 'Admin',
    email: 'admin@taskko.app',
    points: 4120,
    streakDays: 22,
    shields: 4,
    mood: Mood.firedUp,
    isAdmin: true,
  );

  static List<TaskItem> todayTasks() => const [
        TaskItem(id: 't1', title: 'Read CS-201 lecture 7 notes', minutes: 30, points: 40, goal: 'CS-201 midterm', done: true),
        TaskItem(id: 't2', title: 'Practice 5 BST problems', minutes: 45, points: 60, goal: 'CS-201 midterm', done: true),
        TaskItem(id: 't3', title: 'Draft sociology essay intro', minutes: 25, points: 30, goal: 'Essay due Friday'),
        TaskItem(id: 't4', title: 'Review flashcards: Stats', minutes: 20, points: 25, goal: 'Stats quiz Mon'),
        TaskItem(id: 't5', title: 'Email TA about extension', minutes: 5, points: 10, goal: 'Admin'),
      ];

  static List<PlanTask> planReview() => const [
        PlanTask(id: 'p1', title: 'Re-read chapters 5 & 6', minutes: 45, points: 60),
        PlanTask(id: 'p2', title: 'Solve 10 graph traversal problems', minutes: 60, points: 80),
        PlanTask(id: 'p3', title: 'Watch recitation recordings', minutes: 40, points: 45),
        PlanTask(id: 'p4', title: 'Build DP cheat sheet', minutes: 35, points: 50),
        PlanTask(id: 'p5', title: 'Take a timed mock exam', minutes: 90, points: 120),
        PlanTask(id: 'p6', title: 'Review missed mock questions', minutes: 30, points: 40),
      ];

  static List<BadgeItem> badges() => const [
        BadgeItem(key: 'streak5', title: '5 streak', emoji: '🔥', unlocked: true),
        BadgeItem(key: 'first_win', title: 'First win', emoji: '⭐', unlocked: true),
        BadgeItem(key: 'night_owl', title: 'Night owl', emoji: '🌙', unlocked: true),
        BadgeItem(key: 'speedrun', title: 'Speedrun', emoji: '⚡', unlocked: true),
        BadgeItem(key: 'deep_focus', title: 'Deep focus', emoji: '🎧'),
        BadgeItem(key: 'squad_up', title: 'Squad up', emoji: '🤝'),
        BadgeItem(key: 'phoenix', title: 'Phoenix', emoji: '🐦‍🔥'),
        BadgeItem(key: 'legend', title: 'Legend', emoji: '👑'),
        BadgeItem(key: 'scholar', title: 'Scholar', emoji: '🎓'),
      ];

  static List<LeaderboardEntry> leaderboard() => const [
        LeaderboardEntry(position: 1, name: 'Ali Raza', points: 2310),
        LeaderboardEntry(position: 2, name: 'You', points: 1240, isYou: true),
        LeaderboardEntry(position: 3, name: 'Zara Ahmed', points: 980),
        LeaderboardEntry(position: 4, name: 'Bilal Toor', points: 760),
        LeaderboardEntry(position: 5, name: 'Hina Sheikh', points: 540),
      ];

  static WeeklyReport weeklyReport() => const WeeklyReport(
        tasksDone: 18,
        points: 640,
        focusMinutes: 420,
        streakDays: 5,
        topGoal: 'CS-201 midterm',
      );

  static List<ChatMessage> chat() => const [
        ChatMessage(
          from: ChatSender.tako,
          text: "Hey! I noticed your CS reading is overdue by a day. No drama — want me to slot it into tonight, or push it to tomorrow?",
        ),
        ChatMessage(
          from: ChatSender.tako,
          kind: ChatKind.nudge,
          text: "Your 5-day streak is alive 🔥 One 25-minute task tonight keeps it going.",
          actions: ['Start a session', 'Remind me in 1h'],
        ),
        ChatMessage(from: ChatSender.me, text: "I'm stuck on the practice problems, can't focus"),
        ChatMessage(
          from: ChatSender.tako,
          text: "Totally fair. Let's shrink the next task — pick the smallest piece you can finish in 10 minutes and I'll start a focus timer. Often momentum > motivation.",
        ),
      ];
}
