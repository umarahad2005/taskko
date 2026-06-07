import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/focus_session.dart';
import '../../models/mood.dart';
import '../session_repository.dart';

class SessionRepositoryFirestore implements SessionRepository {
  SessionRepositoryFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_auth.currentUser!.uid).collection('sessions');

  Mood _parseMood(String? s) =>
      Mood.values.firstWhere((m) => m.name == s, orElse: () => Mood.focused);

  @override
  Future<void> logSession({
    required String taskTitle,
    required int minutes,
    required Mood mood,
    int? rating,
  }) async {
    await _col.add({
      'taskTitle': taskTitle,
      'minutes': minutes,
      'mood': mood.name,
      'rating': rating,
      'startedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<FocusSession>> recent({int limit = 60}) async {
    final snap = await _col.orderBy('startedAt', descending: true).limit(limit).get();
    return snap.docs.map((doc) {
      final d = doc.data();
      final ts = d['startedAt'];
      return FocusSession(
        id: doc.id,
        taskTitle: (d['taskTitle'] as String?) ?? 'Focus session',
        minutes: (d['minutes'] as num?)?.toInt() ?? 0,
        mood: _parseMood(d['mood'] as String?),
        startedAt: ts is Timestamp ? ts.toDate() : DateTime.now(),
        rating: (d['rating'] as num?)?.toInt(),
      );
    }).toList();
  }
}
