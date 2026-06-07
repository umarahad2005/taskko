import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// System (heads-up) notifications for focus-session end + break reminders
/// (SRS FR-10.1/10.5). Robust to non-Android platforms (errors are swallowed).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready) return;
    try {
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      await _plugin.initialize(settings: const InitializationSettings(android: android));
      await _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      tzdata.initializeTimeZones();
      try {
        tz.setLocalLocation(tz.getLocation((await FlutterTimezone.getLocalTimezone()).identifier));
      } catch (_) {}
      _ready = true;
    } catch (_) {
      // Non-Android / unsupported platform — ignore.
    }
  }

  Future<void> show(String title, String body) async {
    try {
      const details = NotificationDetails(
        android: AndroidNotificationDetails(
          'taskko_focus',
          'Focus & reminders',
          channelDescription: 'Focus-session timers and break reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
      );
      await _plugin.show(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000 % 100000,
        title: title,
        body: body,
        notificationDetails: details,
      );
    } catch (_) {}
  }

  /// Schedule a notification that repeats every day at [hour]:[minute] (FR-10.1/10.5).
  Future<void> scheduleDaily({
    required int id,
    required int hour,
    required int minute,
    required String title,
    required String body,
  }) async {
    try {
      final now = tz.TZDateTime.now(tz.local);
      var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
      if (!when.isAfter(now)) when = when.add(const Duration(days: 1));
      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'taskko_reminders',
            'Reminders',
            channelDescription: 'Daily plan & streak reminders',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  Future<void> cancel(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {}
  }
}
