import '../models/reminder_prefs.dart';

/// Reminder-preferences boundary (SRS FR-10).
abstract interface class SettingsRepository {
  Future<ReminderPrefs> load();
  Future<void> save(ReminderPrefs prefs);
}
