import '../../models/chat_message.dart';
import '../../models/chat_session.dart';
import '../chat_history_repository.dart';

/// In-memory chat history (offline demos / widget tests).
class ChatHistoryRepositoryMock implements ChatHistoryRepository {
  final Map<String, List<ChatMessage>> _store = {};
  final Map<String, ChatSession> _meta = {};

  @override
  Future<List<ChatSession>> sessions() async {
    final list = _meta.values.toList()
      ..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
    return list;
  }

  @override
  Future<List<ChatMessage>> messages(String sessionId) async =>
      List<ChatMessage>.of(_store[sessionId] ?? const []);

  @override
  Future<void> append(String sessionId, ChatMessage message, {String? title}) async {
    (_store[sessionId] ??= <ChatMessage>[]).add(message);
    final prev = _meta[sessionId];
    final resolvedTitle = (title != null && title.trim().isNotEmpty)
        ? title.trim()
        : (prev?.title ?? 'New chat');
    _meta[sessionId] = ChatSession(
      id: sessionId,
      title: resolvedTitle,
      preview: message.text,
      updatedAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteSession(String sessionId) async {
    _store.remove(sessionId);
    _meta.remove(sessionId);
  }

  @override
  Future<void> clearAll() async {
    _store.clear();
    _meta.clear();
  }
}
