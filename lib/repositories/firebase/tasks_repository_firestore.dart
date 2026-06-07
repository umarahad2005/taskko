import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/task_item.dart';
import '../tasks_repository.dart';

/// Real today's-tasks store, backed by `users/{uid}/tasks` (SRS §7.1).
/// New users start with an empty list; tasks are added by the Plan Studio.
class TasksRepositoryFirestore implements TasksRepository {
  TasksRepositoryFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_auth.currentUser!.uid).collection('tasks');

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  @override
  Future<List<TaskItem>> todayTasks() async {
    final snap = await _col.where('date', isEqualTo: _todayKey()).get();
    final tasks = snap.docs.map((doc) {
      final d = doc.data();
      return TaskItem(
        id: doc.id,
        title: (d['title'] as String?) ?? '',
        minutes: (d['minutes'] as num?)?.toInt() ?? 0,
        points: (d['points'] as num?)?.toInt() ?? 0,
        goal: (d['goal'] as String?) ?? '',
        done: (d['status'] as String?) == 'done',
      );
    }).toList();
    return tasks;
  }

  @override
  Future<void> setDone(String id, {required bool done}) async {
    await _col.doc(id).set({
      'status': done ? 'done' : 'todo',
      'completedAt': done ? FieldValue.serverTimestamp() : null,
    }, SetOptions(merge: true));
  }

  @override
  Future<void> addTasks(List<TaskItem> tasks) async {
    final batch = _db.batch();
    final today = _todayKey();
    for (final t in tasks) {
      batch.set(_col.doc(t.id), {
        'title': t.title,
        'minutes': t.minutes,
        'points': t.points,
        'goal': t.goal,
        'status': t.done ? 'done' : 'todo',
        'date': today,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}
