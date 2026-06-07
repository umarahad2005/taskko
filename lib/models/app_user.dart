import 'package:equatable/equatable.dart';

import 'mood.dart';
import 'rank.dart';

/// The signed-in user's profile + gamification state (SRS §7.1 `users/{uid}`).
class AppUser extends Equatable {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.points = 0,
    this.streakDays = 0,
    this.shields = 0,
    this.mood = Mood.focused,
    this.isAdmin = false,
  });

  final String id;
  final String name;
  final String email;
  final int points;
  final int streakDays;
  final int shields;
  final Mood mood;
  final bool isAdmin;

  String get initials => name.isNotEmpty ? name.trim()[0].toUpperCase() : '?';
  Rank get rank => Rank.forPoints(points);

  /// Points still needed to reach the next rank (0 if at the top).
  int get pointsToNext {
    final next = rank.next;
    return next == null ? 0 : (next.threshold - points).clamp(0, next.threshold);
  }

  AppUser copyWith({
    int? points,
    int? streakDays,
    int? shields,
    Mood? mood,
  }) {
    return AppUser(
      id: id,
      name: name,
      email: email,
      points: points ?? this.points,
      streakDays: streakDays ?? this.streakDays,
      shields: shields ?? this.shields,
      mood: mood ?? this.mood,
      isAdmin: isAdmin,
    );
  }

  @override
  List<Object?> get props => [id, name, email, points, streakDays, shields, mood, isAdmin];
}
