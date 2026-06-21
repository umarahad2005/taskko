import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/chat_message.dart';
import '../../models/chat_session.dart';
import '../chat_history_repository.dart';

/// Real chat history, backed by `users/{uid}/chatSessions/{sessionId}` with a
/// `messages` subcollection (SRS §7.1).
class ChatHistoryRepositoryFirestore implements ChatHistoryRepository {
  ChatHistoryRepositoryFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_auth.currentUser!.uid).collection('chatSessions');

  static String _clip(String s, int n) => s.length > n ? '${s.substring(0, n)}…' : s;

  @override
  Future<List<ChatSession>> sessions() async {
    final snap = await _col.orderBy('updatedAt', descending: true).limit(30).get();
    return snap.docs.map((d) {
      final m = d.data();
      final ts = m['updatedAt'];
      final title = (m['title'] as String?)?.trim();
      return ChatSession(
        id: d.id,
        title: (title != null && title.isNotEmpty) ? title : 'New chat',
        preview: (m['preview'] as String?) ?? '',
        updatedAt: ts is Timestamp ? ts.toDate() : null,
      );
    }).toList();
  }

  @override
  Future<List<ChatMessage>> messages(String sessionId) async {
    final snap = await _col.doc(sessionId).collection('messages').orderBy('ts').limit(300).get();
    return snap.docs.map((d) {
      final m = d.data();
      return ChatMessage(
        from: (m['from'] as String?) == 'me' ? ChatSender.me : ChatSender.tako,
        text: (m['text'] as String?) ?? '',
      );
    }).toList();
  }

  @override
  Future<void> append(String sessionId, ChatMessage message, {String? title}) async {
    final doc = _col.doc(sessionId);
    final data = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
      'preview': _clip(message.text, 80),
    };
    if (title != null && title.trim().isNotEmpty) {
      data['title'] = _clip(title.trim(), 60);
      data['createdAt'] = FieldValue.serverTimestamp();
    }
    await doc.set(data, SetOptions(merge: true));
    await doc.collection('messages').add({
      'from': message.from == ChatSender.me ? 'me' : 'tako',
      'text': message.text,
      'ts': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    final msgs = await _col.doc(sessionId).collection('messages').get();
    for (final d in msgs.docs) {
      await d.reference.delete();
    }
    await _col.doc(sessionId).delete();
  }

  @override
  Future<void> clearAll() async {
    // No signed-in user → nothing to clear (avoids a null-uid crash if called
    // right after sign-out).
    if (_auth.currentUser == null) return;
    final sessions = await _col.get();
    for (final session in sessions.docs) {
      final msgs = await session.reference.collection('messages').get();
      for (final m in msgs.docs) {
        await m.reference.delete();
      }
      await session.reference.delete();
    }
  }
}
