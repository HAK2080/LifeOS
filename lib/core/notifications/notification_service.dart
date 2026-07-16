import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  Future<void> init() async {
    if (_ready || kIsWeb) return;
    tz.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } catch (_) {
      // Fall back to UTC offset if the platform timezone can't be resolved.
    }
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings: settings);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _ready = true;
  }

  Future<void> scheduleTaskReminder({
    required int taskId,
    required String title,
    required DateTime when,
  }) async {
    if (kIsWeb) return;
    await init();
    if (when.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: taskId,
      title: title,
      body: null,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task reminders',
          channelDescription: 'Reminders you set on tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelTaskReminder(int taskId) async {
    if (kIsWeb) return;
    await _plugin.cancel(id: taskId);
  }

  static const _restTimerId = 900001;

  /// Fires when the rest timer ends, even with the screen locked.
  Future<void> scheduleRestDone(DateTime when) async {
    if (kIsWeb) return;
    await init();
    if (when.isBefore(DateTime.now())) return;
    await _plugin.zonedSchedule(
      id: _restTimerId,
      title: 'Rest over — next set',
      body: null,
      scheduledDate: tz.TZDateTime.from(when, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'rest_timer',
          'Rest timer',
          channelDescription: 'Fires when your rest period ends',
          importance: Importance.max,
          priority: Priority.high,
          category: AndroidNotificationCategory.alarm,
          enableVibration: true,
          playSound: true,
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelRestDone() async {
    if (kIsWeb) return;
    await _plugin.cancel(id: _restTimerId);
  }
}

final notificationServiceProvider =
    Provider<NotificationService>((ref) => NotificationService());
