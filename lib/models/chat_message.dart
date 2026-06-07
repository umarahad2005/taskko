import 'package:equatable/equatable.dart';

enum ChatSender { me, tako }

enum ChatKind { text, nudge }

/// A Tako chat message (SRS §7.1 `users/{uid}/chats/{id}`, FR-7).
class ChatMessage extends Equatable {
  const ChatMessage({
    required this.from,
    required this.text,
    this.kind = ChatKind.text,
    this.actions = const [],
  });

  final ChatSender from;
  final String text;
  final ChatKind kind;
  final List<String> actions;

  @override
  List<Object?> get props => [from, text, kind, actions];
}
