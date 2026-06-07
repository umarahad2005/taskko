import 'package:equatable/equatable.dart';

/// User reminder preferences (SRS FR-10.1/10.5), stored at
/// `users/{uid}/settings/reminders`.
class ReminderPrefs extends Equatable {
  const ReminderPrefs({
    this.planDaily = false,
    this.planHour = 9,
    this.planMinute = 0,
    this.streakSaver = false,
  });

  final bool planDaily;
  final int planHour;
  final int planMinute;
  final bool streakSaver;

  ReminderPrefs copyWith({bool? planDaily, int? planHour, int? planMinute, bool? streakSaver}) =>
      ReminderPrefs(
        planDaily: planDaily ?? this.planDaily,
        planHour: planHour ?? this.planHour,
        planMinute: planMinute ?? this.planMinute,
        streakSaver: streakSaver ?? this.streakSaver,
      );

  Map<String, dynamic> toMap() => {
        'planDaily': planDaily,
        'planHour': planHour,
        'planMinute': planMinute,
        'streakSaver': streakSaver,
      };

  factory ReminderPrefs.fromMap(Map<String, dynamic>? m) {
    final d = m ?? const {};
    return ReminderPrefs(
      planDaily: (d['planDaily'] as bool?) ?? false,
      planHour: (d['planHour'] as num?)?.toInt() ?? 9,
      planMinute: (d['planMinute'] as num?)?.toInt() ?? 0,
      streakSaver: (d['streakSaver'] as bool?) ?? false,
    );
  }

  @override
  List<Object?> get props => [planDaily, planHour, planMinute, streakSaver];
}
