import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../data/models/study_task_model.dart';

class NotificationService {
  NotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;

  static Future<NotificationService> init() async {
    final plugin = FlutterLocalNotificationsPlugin();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();

    await plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _handleNotificationResponse,
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    return NotificationService(plugin);
  }

  Future<void> requestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, sound: true, badge: true);
  }

  Future<void> scheduleTaskReminder(StudyTaskModel task) async {
    final reminderAt = task.reminderAt;
    if (reminderAt == null) return;

    final scheduleDates = _buildScheduleDates(task);
    for (var i = 0; i < scheduleDates.length; i++) {
      final scheduleDate = tz.TZDateTime.from(scheduleDates[i], tz.local);
      await _plugin.zonedSchedule(
        task.notificationId + i,
        'Study reminder: ${task.subject}',
        task.task,
        scheduleDate,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'study_tasks',
            'Study Tasks',
            channelDescription: 'Reminders for study tasks',
            importance: Importance.max,
            priority: Priority.high,
            actions: [
              const AndroidNotificationAction('snooze_5', 'Snooze 5m'),
              const AndroidNotificationAction('snooze_10', 'Snooze 10m'),
              const AndroidNotificationAction('snooze_30', 'Snooze 30m'),
            ],
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: _buildPayload(task),
      );
    }
  }

  Future<void> cancelTaskReminder(StudyTaskModel task) async {
    final scheduleDates = _buildScheduleDates(task);
    for (var i = 0; i < scheduleDates.length; i++) {
      await _plugin.cancel(task.notificationId + i);
    }
  }

  static Future<void> _handleNotificationResponse(
    NotificationResponse response,
  ) async {
    final actionId = response.actionId ?? '';
    if (!actionId.startsWith('snooze_')) return;
    final payload = response.payload;
    if (payload == null) return;
    final data = _parsePayload(payload);
    if (data == null) return;
    final plugin = FlutterLocalNotificationsPlugin();
    final minutes = _parseSnoozeMinutes(actionId);
    final snoozeTime = tz.TZDateTime.now(tz.local).add(
      Duration(minutes: minutes),
    );
    await plugin.zonedSchedule(
      DateTime.now().millisecondsSinceEpoch,
      data.title,
      data.body,
      snoozeTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'study_tasks',
          'Study Tasks',
          channelDescription: 'Reminders for study tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  static String _buildPayload(StudyTaskModel task) {
    return '${task.subject}||${task.task}';
  }

  static _PayloadData? _parsePayload(String payload) {
    final parts = payload.split('||');
    if (parts.length != 2) return null;
    return _PayloadData(parts[0], parts[1]);
  }

  static int _parseSnoozeMinutes(String actionId) {
    final parts = actionId.split('_');
    if (parts.length != 2) return 10;
    return int.tryParse(parts[1]) ?? 10;
  }

  List<DateTime> _buildScheduleDates(StudyTaskModel task) {
    final reminderAt = task.reminderAt;
    if (reminderAt == null) return [];

    if (task.recurrence == RecurrenceRule.none ||
        task.repeatUntil == null ||
        task.repeatUntil!.isBefore(reminderAt)) {
      return [reminderAt];
    }

    final dates = <DateTime>[];
    var current = reminderAt;
    final limit = task.repeatUntil!;
    var safety = 0;
    while (!current.isAfter(limit) && safety < 366) {
      dates.add(current);
      safety++;
      current = switch (task.recurrence) {
        RecurrenceRule.daily => current.add(const Duration(days: 1)),
        RecurrenceRule.weekly => current.add(const Duration(days: 7)),
        RecurrenceRule.none => current,
      };
    }
    return dates;
  }
}

class _PayloadData {
  _PayloadData(this.title, this.body);

  final String title;
  final String body;
}
