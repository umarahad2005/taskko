import 'package:equatable/equatable.dart';

/// A milestone badge (SRS §7.1 `users/{uid}/badges/{id}`, FR-8.5).
class BadgeItem extends Equatable {
  const BadgeItem({
    required this.key,
    required this.title,
    required this.emoji,
    this.unlocked = false,
  });

  final String key;
  final String title;
  final String emoji;
  final bool unlocked;

  @override
  List<Object?> get props => [key, title, emoji, unlocked];
}
