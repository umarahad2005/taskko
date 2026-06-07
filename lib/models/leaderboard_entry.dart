import 'package:equatable/equatable.dart';

/// One row in the squad leaderboard (SRS FR-6.4).
class LeaderboardEntry extends Equatable {
  const LeaderboardEntry({
    required this.position,
    required this.name,
    required this.points,
    this.isYou = false,
  });

  final int position;
  final String name;
  final int points;
  final bool isYou;

  @override
  List<Object?> get props => [position, name, points, isYou];
}
