import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../common/view_status.dart';
import '../../../models/chat_message.dart';
import '../../../models/chat_session.dart';
import '../../../repositories/chat_history_repository.dart';
import '../../../repositories/chat_repository.dart';

part 'chat_state.dart';

/// Tako AI chat (SRS FR-7). Replies come from the [ChatRepository]; when a
/// [ChatHistoryRepository] is provided, conversations are persisted so the user
/// can reopen past sessions from the chat menu.
class ChatCubit extends Cubit<ChatState> {
  ChatCubit(this._repo, {ChatHistoryRepository? history})
      : _history = history,
        super(const ChatState());

  final ChatRepository _repo;
  final ChatHistoryRepository? _history;

  int _idSeed = 0;
  String _newId() => 's${DateTime.now().millisecondsSinceEpoch}_${_idSeed++}';

  Future<void> load() async {
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final greeting = await _repo.history();
      final sessions = _history == null ? const <ChatSession>[] : await _history.sessions();
      if (sessions.isNotEmpty) {
        // Reopen the most recent conversation.
        final id = sessions.first.id;
        final msgs = await _history!.messages(id);
        emit(state.copyWith(
          status: ViewStatus.success,
          messages: msgs.isEmpty ? greeting : msgs,
          sessions: sessions,
          currentSessionId: id,
        ));
      } else {
        emit(state.copyWith(
          status: ViewStatus.success,
          messages: greeting,
          sessions: sessions,
          currentSessionId: _newId(),
        ));
      }
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }

  /// Start a fresh conversation (keeps history; just opens a new session).
  Future<void> newChat() async {
    final greeting = await _repo.history();
    emit(state.copyWith(messages: greeting, currentSessionId: _newId(), isTyping: false));
  }

  /// Reopen a past conversation by id.
  Future<void> openSession(String id) async {
    if (_history == null) return;
    emit(state.copyWith(status: ViewStatus.loading));
    try {
      final msgs = await _history.messages(id);
      emit(state.copyWith(status: ViewStatus.success, messages: msgs, currentSessionId: id));
    } catch (_) {
      emit(state.copyWith(status: ViewStatus.failure));
    }
  }

  Future<void> refreshSessions() async {
    if (_history == null) return;
    emit(state.copyWith(sessions: await _history.sessions()));
  }

  Future<void> deleteSession(String id) async {
    if (_history == null) return;
    await _history.deleteSession(id);
    final sessions = await _history.sessions();
    if (id == state.currentSessionId) {
      final greeting = await _repo.history();
      emit(state.copyWith(messages: greeting, currentSessionId: _newId(), sessions: sessions));
    } else {
      emit(state.copyWith(sessions: sessions));
    }
  }

  /// Send a user message and append Tako's reply, with a typing indicator and a
  /// graceful fallback on failure (SRS FR-7.2/7.3/7.6). Persists both messages.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final sessionId = state.currentSessionId ?? _newId();
    final isFirstUserMsg = !state.messages.any((m) => m.from == ChatSender.me);
    final userMsg = ChatMessage(from: ChatSender.me, text: trimmed);
    final withUser = [...state.messages, userMsg];
    emit(state.copyWith(messages: withUser, isTyping: true, currentSessionId: sessionId));
    await _history?.append(sessionId, userMsg, title: isFirstUserMsg ? trimmed : null);

    try {
      final reply = await _repo.send(trimmed);
      emit(state.copyWith(messages: [...withUser, reply], isTyping: false));
      await _history?.append(sessionId, reply);
    } catch (_) {
      const fallback = ChatMessage(
        from: ChatSender.tako,
        text: "I'm having trouble responding right now — but try one small task and tell me how it goes.",
      );
      emit(state.copyWith(messages: [...withUser, fallback], isTyping: false));
      await _history?.append(sessionId, fallback);
    }
    await refreshSessions();
  }
}
