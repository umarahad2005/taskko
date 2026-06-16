import '../models/chat_message.dart';
import '../models/chat_session.dart';

/// Persistence boundary for Tako chat history (SRS FR-7). Stores conversations
/// so the user can reopen past sessions from the chat menu.
abstract interface class ChatHistoryRepository {
  /// Past sessions, most-recently-updated first.
  Future<List<ChatSession>> sessions();

  /// All messages of one session, oldest first.
  Future<List<ChatMessage>> messages(String sessionId);

  /// Append a message to a session (creating/refreshing the session doc).
  /// [title] is set once, from the first user message of the session.
  Future<void> append(String sessionId, ChatMessage message, {String? title});

  /// Delete a session and all its messages.
  Future<void> deleteSession(String sessionId);
}
