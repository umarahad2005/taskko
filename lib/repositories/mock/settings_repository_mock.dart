import '../../models/reminder_prefs.dart';
import '../settings_repository.dart';

class SettingsRepositoryMock implements SettingsRepository {
  ReminderPrefs _prefs = const ReminderPrefs();

  @override
  Future<ReminderPrefs> load() async => _prefs;

  @override
  Future<void> save(ReminderPrefs prefs) async => _prefs = prefs;
}
