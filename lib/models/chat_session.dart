import 'package:equatable/equatable.dart';

/// A saved Tako conversation (SRS §7.1 `users/{uid}/chatSessions/{id}`), shown
/// in the chat history menu so the user can reopen past chats.
class ChatSession extends Equatable {
  const ChatSession({
    required this.id,
    required this.title,
    required this.preview,
    this.updatedAt,
  });

  final String id;
  final String title;
  final String preview;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [id, title, preview, updatedAt];
}
