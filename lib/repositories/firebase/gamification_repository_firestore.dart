import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/app_user.dart';
import '../../models/badge_item.dart';
import '../../models/leaderboard_entry.dart';
import '../../models/mood.dart';
import '../../models/weekly_report.dart';
import '../gamification_repository.dart';

/// Real profile + gamification, backed by Cloud Firestore `users/{uid}`
/// (SRS §7.1). New accounts start at zero and grow with real usage — no seed.
class GamificationRepositoryFirestore implements GamificationRepository {
  GamificationRepositoryFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid => _auth.currentUser!.uid;
  DocumentReference<Map<String, dynamic>> get _doc => _db.collection('users').doc(_uid);
  DocumentReference<Map<String, dynamic>> get _publicDoc =>
      _db.collection('public_profiles').doc(_uid);

  /// Mirror a public, leaderboard-readable copy of the profile (M14).
  /// Fire-and-forget so it never blocks the UI path.
  void _mirrorPublic(AppUser u) {
    _publicDoc.set({
      'name': u.name,
      'points': u.points,
      'rank': u.rank.label,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static String _dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Mood _parseMood(String? s) =>
      Mood.values.firstWhere((m) => m.name == s, orElse: () => Mood.focused);

  AppUser _fromDoc(String uid, Map<String, dynamic> d) => AppUser(
        id: uid,
        name: (d['name'] as String?)?.trim().isNotEmpty == true ? d['name'] as String : 'Student',
        email: (d['email'] as String?) ?? '',
        points: (d['points'] as num?)?.toInt() ?? 0,
        streakDays: (d['streakDays'] as num?)?.toInt() ?? 0,
        shields: (d['shields'] as num?)?.toInt() ?? 0,
        mood: _parseMood(d['mood'] as String?),
        isAdmin: (d['isAdmin'] as bool?) ?? false,
      );

  @override
  Future<AppUser> profile() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Not signed in');
    final snap = await _doc.get();
    if (!snap.exists) {
      final name = (user.displayName != null && user.displayName!.trim().isNotEmpty)
          ? user.displayName!.trim()
          : (user.email?.split('@').first ?? 'Student');
      await _doc.set({
        'name': name,
        'email': user.email ?? '',
        'points': 0,
        'streakDays': 0,
        'shields': 0,
        'mood': Mood.focused.name,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActiveDate': null,
      });
      final created = AppUser(id: user.uid, name: name, email: user.email ?? '');
      _mirrorPublic(created);
      return created;
    }
    final loaded = _fromDoc(user.uid, snap.data()!);
    _mirrorPublic(loaded);
    return loaded;
  }

  @override
  Future<AppUser> setMood(Mood mood) async {
    await _doc.set({'mood': mood.name}, SetOptions(merge: true));
    final snap = await _doc.get();
    final u = _fromDoc(_uid, snap.data() ?? const {});
    _mirrorPublic(u);
    return u;
  }

  @override
  Future<AppUser> recordTaskCompletion({required int points, required bool nowDone}) async {
    final updated = await _db.runTransaction<Map<String, dynamic>>((tx) async {
      final snap = await tx.get(_doc);
      final d = Map<String, dynamic>.of(snap.data() ?? const {});
      var pts = ((d['points'] as num?)?.toInt() ?? 0) + (nowDone ? points : -points);
      if (pts < 0) pts = 0;
      var streak = (d['streakDays'] as num?)?.toInt() ?? 0;
      var lastActive = d['lastActiveDate'] as String?;
      if (nowDone) {
        final today = _dateKey(DateTime.now());
        if (lastActive != today) {
          final yesterday = _dateKey(DateTime.now().subtract(const Duration(days: 1)));
          streak = lastActive == yesterday ? streak + 1 : 1;
          lastActive = today;
        }
      }
      d['points'] = pts;
      d['streakDays'] = streak;
      d['lastActiveDate'] = lastActive;
      tx.set(_doc, {'points': pts, 'streakDays': streak, 'lastActiveDate': lastActive},
          SetOptions(merge: true));
      return d;
    });
    final u = _fromDoc(_uid, updated);
    _mirrorPublic(u);
    return u;
  }

  @override
  Future<List<BadgeItem>> badges() async {
    final p = await profile();
    // Unlock state derived from REAL profile stats (no mock).
    return [
      BadgeItem(key: 'first_win', title: 'First win', emoji: '⭐', unlocked: p.points > 0),
      BadgeItem(key: 'streak5', title: '5 streak', emoji: '🔥', unlocked: p.streakDays >= 5),
      BadgeItem(key: 'pro', title: 'Pro rank', emoji: '🚀', unlocked: p.points >= 1000),
      BadgeItem(key: 'elite', title: 'Elite', emoji: '💎', unlocked: p.points >= 1560),
      const BadgeItem(key: 'night_owl', title: 'Night owl', emoji: '🌙'),
      const BadgeItem(key: 'deep_focus', title: 'Deep focus', emoji: '🎧'),
      const BadgeItem(key: 'squad_up', title: 'Squad up', emoji: '🤝'),
      BadgeItem(key: 'legend', title: 'Legend', emoji: '👑', unlocked: p.points >= 3000),
      const BadgeItem(key: 'scholar', title: 'Scholar', emoji: '🎓'),
    ];
  }

  @override
  Future<List<LeaderboardEntry>> leaderboard() async {
    final me = _auth.currentUser?.uid;
    final q = await _db
        .collection('public_profiles')
        .orderBy('points', descending: true)
        .limit(20)
        .get();
    var pos = 0;
    return q.docs.map((doc) {
      pos++;
      final d = doc.data();
      return LeaderboardEntry(
        position: pos,
        name: (d['name'] as String?) ?? 'Student',
        points: (d['points'] as num?)?.toInt() ?? 0,
        isYou: doc.id == me,
      );
    }).toList();
  }

  @override
  Future<WeeklyReport> weeklyReport() async {
    final p = await profile();
    final since = DateTime.now().subtract(const Duration(days: 7));
    final snap = await _doc.collection('tasks').where('status', isEqualTo: 'done').get();
    var tasksDone = 0;
    var focus = 0;
    for (final t in snap.docs) {
      final d = t.data();
      final ts = d['completedAt'];
      final when = ts is Timestamp ? ts.toDate() : null;
      if (when == null || when.isAfter(since)) {
        tasksDone++;
        focus += (d['minutes'] as num?)?.toInt() ?? 0;
      }
    }
    return WeeklyReport(
      tasksDone: tasksDone,
      points: p.points,
      focusMinutes: focus,
      streakDays: p.streakDays,
      topGoal: '—',
    );
  }
}
