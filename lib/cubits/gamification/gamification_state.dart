part of 'gamification_cubit.dart';

class GamificationState extends Equatable {
  const GamificationState({
    this.status = ViewStatus.initial,
    this.user,
    this.badges = const [],
  });

  final ViewStatus status;
  final AppUser? user;
  final List<BadgeItem> badges;

  GamificationState copyWith({ViewStatus? status, AppUser? user, List<BadgeItem>? badges}) =>
      GamificationState(
        status: status ?? this.status,
        user: user ?? this.user,
        badges: badges ?? this.badges,
      );

  @override
  List<Object?> get props => [status, user, badges];
}
