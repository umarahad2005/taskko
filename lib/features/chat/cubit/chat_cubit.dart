import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/chat_message.dart';
import '../../../repositories/chat_repository.dart';

part 'chat_state.dart';

/// Tako AI chat (SRS FR-7). Depends on the [ChatRepository] interface; the mock
/// picks replies by intent, the real impl calls `/api/ai/chat` (Gemini) in M9.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repo) : super(const ChatState());

  final ChatRepository _repo;

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final messages = await _repo.history();
      emit(state.copyWith(status: ViewStatus.success, messages: messages));
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }

  /// Send a user message and append Tako's reply, with a typing indicator and
  /// a graceful fallback on failure (SRS FR-7.2/7.3/7.6).
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final withUser = [...state.messages, ChatMessage(from: ChatSender.me, text: trimmed)];
    emit(state.copyWith(messages: withUser, isTyping: true));

    try {
      final reply = await _repo.send(trimmed);
      emit(state.copyWith(messages: [...withUser, reply], isTyping: false));
    } catch (_) {
      const fallback = ChatMessage(
        from: ChatSender.tako,
        text: "I'm having trouble responding right now — but try one small task and tell me how it goes.",
      );
      emit(state.copyWith(messages: [...withUser, fallback], isTyping: false));
    }
  }
}
