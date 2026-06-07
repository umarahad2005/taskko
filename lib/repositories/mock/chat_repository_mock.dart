import '../../models/chat_message.dart';
import '../chat_repository.dart';
import 'seed.dart';

/// Intent-based mock replies for Tako (SRS FR-7.2). Picks a response by simple
/// keyword matching, mirroring the prototype's behavior.
class ChatRepositoryMock implements ChatRepository {
  @override
  Future<List<ChatMessage>> history() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return Seed.chat();
  }

  @override
  Future<ChatMessage> send(String message) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    final m = message.toLowerCase();
    if (m.contains('motivat')) {
      return const ChatMessage(
        from: ChatSender.tako,
        text: "You're 320 points from Elite and on a 5-day streak. One task at a time. 🚀",
      );
    }
    if (m.contains('break') || m.contains('tired')) {
      return const ChatMessage(
        from: ChatSender.tako,
        text: "Good call — rest is part of the plan. Take 10 minutes, then I'll line up one small task to keep the streak alive.",
      );
    }
    if (m.contains('plan') || m.contains('evening')) {
      return const ChatMessage(
        from: ChatSender.tako,
        kind: ChatKind.nudge,
        text: "Let's plan tonight. I can break your essay goal into 3 quick steps — want me to?",
        actions: ['Break it down', 'Not now'],
      );
    }
    return const ChatMessage(
      from: ChatSender.tako,
      text: "Got it. Let's shrink the next task to something you can finish in 10 minutes — momentum beats motivation.",
    );
  }
}
