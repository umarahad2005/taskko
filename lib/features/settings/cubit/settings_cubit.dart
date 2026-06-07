import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../models/reminder_prefs.dart';
import '../../../repositories/settings_repository.dart';
import '../../../services/notification_service.dart';

/// Manages reminder preferences and (re)schedules the matching daily
/// notifications whenever they change (SRS FR-10.1/10.5).
class SettingsCubit extends Cubit<ReminderPrefs> {
  SettingsCubit(this._repo) : super(const ReminderPrefs());

  final SettingsRepository _repo;

  static const _planId = 1001;
  static const _streakId = 1002;

  Future<void> load() async {
    final prefs = await _repo.load();
    emit(prefs);
    await _apply(prefs);
  }

  void setPlanDaily(bool value) => _update(state.copyWith(planDaily: value));
  void setPlanTime(int hour, int minute) => _update(state.copyWith(planHour: hour, planMinute: minute));
  void setStreakSaver(bool value) => _update(state.copyWith(streakSaver: value));

  Future<void> _update(ReminderPrefs prefs) async {
    emit(prefs);
    await _repo.save(prefs);
    await _apply(prefs);
  }

  Future<void> _apply(ReminderPrefs p) async {
    final n = NotificationService.instance;
    if (p.planDaily) {
      await n.scheduleDaily(
        id: _planId,
        hour: p.planHour,
        minute: p.planMinute,
        title: 'Plan your day 📋',
        body: 'Take 2 minutes to set up Taskko for today.',
      );
    } else {
      await n.cancel(_planId);
    }
    if (p.streakSaver) {
      await n.scheduleDaily(
        id: _streakId,
        hour: 20,
        minute: 0,
        title: 'Keep your streak alive 🔥',
        body: 'One quick task tonight keeps your streak going!',
      );
    } else {
      await n.cancel(_streakId);
    }
  }
}
