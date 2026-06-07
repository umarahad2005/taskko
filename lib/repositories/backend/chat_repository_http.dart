import '../../models/chat_message.dart';
import '../chat_repository.dart';
import 'ai_api_client.dart';

/// Real Tako chat repository — calls the backend `/api/ai/chat` (Gemini)
/// instead of the intent-matching mock (SRS FR-7.2). Chat history persistence
/// (Firestore) is a later M9 slice; here we open with a greeting.
class ChatRepositoryHttp implements ChatRepository {
  ChatRepositoryHttp(this._api);

  final AiApiClient _api;

  @override
  Future<List<ChatMessage>> history() async => const [
        ChatMessage(
          from: ChatSender.tako,
          text: "Hey! I'm Tako 👋 Tell me what you're working on and I'll help you plan it.",
        ),
      ];

  @override
  Future<ChatMessage> send(String message) async {
    final json = await _api.postJson('/api/ai/chat', {'message': message, 'context': <String, dynamic>{}});
    final reply = (json['reply'] as String?)?.trim();
    return ChatMessage(
      from: ChatSender.tako,
      text: reply == null || reply.isEmpty ? "Let's take one small step — what's the next tiny task?" : reply,
    );
  }
}
