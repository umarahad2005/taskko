import '../models/chat_message.dart';

/// Tako chat boundary (SRS FR-7). The mock picks replies by intent; the real
/// impl calls `POST /api/ai/chat` (Gemini) in M9.
abstract interface class ChatRepository {
  Future<List<ChatMessage>> history();
  Future<ChatMessage> send(String message);
}
