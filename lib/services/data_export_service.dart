import 'dart:convert';
import 'dart:io';

import 'package:share_plus/share_plus.dart';

import '../repositories/chat_history_repository.dart';
import '../repositories/gamification_repository.dart';
import '../repositories/session_repository.dart';
import '../repositories/tasks_repository.dart';

/// Gathers the signed-in user's data into a JSON file and shares it — the
/// GDPR "right to access / data portability" companion to account deletion.
class DataExportService {
  const DataExportService({
    required this.gamification,
    required this.tasks,
    required this.sessions,
    required this.chats,
  });

  final GamificationRepository gamification;
  final TasksRepository tasks;
  final SessionRepository sessions;
  final ChatHistoryRepository chats;

  Future<void> exportAndShare() async {
    final user = await gamification.profile();
    final today = await tasks.todayTasks();
    final recent = await sessions.recent(limit: 100);
    final chatSessions = await chats.sessions();

    final data = <String, dynamic>{
      'app': 'Taskko',
      'exportedAt': DateTime.now().toIso8601String(),
      'profile': {
        'name': user.name,
        'email': user.email,
        'rank': user.rank.label,
        'points': user.points,
        'streakDays': user.streakDays,
        'shields': user.shields,
        'mood': user.mood.name,
      },
      'todaysTasks': [
        for (final t in today)
          {'title': t.title, 'minutes': t.minutes, 'points': t.points, 'goal': t.goal, 'done': t.done},
      ],
      'focusSessions': [
        for (final s in recent)
          {
            'taskTitle': s.taskTitle,
            'minutes': s.minutes,
            'mood': s.mood.name,
            'rating': s.rating,
            'startedAt': s.startedAt.toIso8601String(),
          },
      ],
      'chatSessions': [
        for (final c in chatSessions)
          {'title': c.title, 'preview': c.preview, 'updatedAt': c.updatedAt?.toIso8601String()},
      ],
    };

    final json = const JsonEncoder.withIndent('  ').convert(data);
    final file = File('${Directory.systemTemp.path}/taskko_my_data.json');
    await file.writeAsString(json);
    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path, mimeType: 'application/json')], text: 'My Taskko data export'),
    );
  }
}
