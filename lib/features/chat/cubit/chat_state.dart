part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = ViewStatus.initial,
    this.messages = const [],
    this.isTyping = false,
    this.sessions = const [],
    this.currentSessionId,
  });

  final ViewStatus status;
  final List<ChatMessage> messages;
  final bool isTyping;

  /// Past saved conversations (for the history menu).
  final List<ChatSession> sessions;

  /// The session messages are currently being read/written to.
  final String? currentSessionId;

  ChatState copyWith({
    ViewStatus? status,
    List<ChatMessage>? messages,
    bool? isTyping,
    List<ChatSession>? sessions,
    String? currentSessionId,
  }) =>
      ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
        sessions: sessions ?? this.sessions,
        currentSessionId: currentSessionId ?? this.currentSessionId,
      );

  @override
  List<Object?> get props => [status, messages, isTyping, sessions, currentSessionId];
}
