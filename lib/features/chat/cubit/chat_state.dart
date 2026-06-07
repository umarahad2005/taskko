part of 'chat_cubit.dart';

class ChatState extends Equatable {
  const ChatState({
    this.status = ViewStatus.initial,
    this.messages = const [],
    this.isTyping = false,
  });

  final ViewStatus status;
  final List<ChatMessage> messages;
  final bool isTyping;

  ChatState copyWith({ViewStatus? status, List<ChatMessage>? messages, bool? isTyping}) => ChatState(
        status: status ?? this.status,
        messages: messages ?? this.messages,
        isTyping: isTyping ?? this.isTyping,
      );

  @override
  List<Object?> get props => [status, messages, isTyping];
}
