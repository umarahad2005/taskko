import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/reminder_prefs.dart';
import '../settings_repository.dart';

class SettingsRepositoryFirestore implements SettingsRepository {
  SettingsRepositoryFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  DocumentReference<Map<String, dynamic>> get _doc =>
      _db.collection('users').doc(_auth.currentUser!.uid).collection('settings').doc('reminders');

  @override
  Future<ReminderPrefs> load() async {
    final snap = await _doc.get();
    return ReminderPrefs.fromMap(snap.data());
  }

  @override
  Future<void> save(ReminderPrefs prefs) => _doc.set(prefs.toMap(), SetOptions(merge: true));
}
