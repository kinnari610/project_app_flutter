import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  static const MethodChannel _channel = MethodChannel('com.mototek.portal/timezone');

  static Future<void> initialize() async {
    tz.initializeTimeZones();
    
    try {
      final String? timeZoneName = await _channel.invokeMethod('getTimezone');
      if (timeZoneName != null) {
        try {
          // Try to set the location returned by the system
          tz.setLocalLocation(tz.getLocation(timeZoneName));
        } catch (e) {
          // Fallback: If "Asia/Calcutta" fails, try "Asia/Kolkata"
          if (timeZoneName == "Asia/Calcutta") {
            tz.setLocalLocation(tz.getLocation("Asia/Kolkata"));
          } else {
            // Default to UTC if all else fails to prevent crash
            tz.setLocalLocation(tz.UTC);
          }
          debugPrint("Timezone fallback used for: $timeZoneName");
        }
        debugPrint("Timezone initialized: ${tz.local.name}");
      }
    } catch (e) {
      debugPrint("Failed to get timezone via channel: $e");
    }

    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(android: androidSettings);

    await _notifications.initialize(settings);

    if (Platform.isAndroid) {
      final androidImplementation = _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      
      await androidImplementation?.requestNotificationsPermission();
    }
  }

  static Future<void> openAlarmSettings() async {
    if (Platform.isAndroid) {
      const intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
        data: 'package:com.example.project_app_flutter',
        flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
      );
      try {
        await intent.launch();
      } catch (e) {
        debugPrint("Could not open alarm settings: $e");
        const intentGeneral = AndroidIntent(
          action: 'android.settings.SETTINGS',
          flags: [Flag.FLAG_ACTIVITY_NEW_TASK],
        );
        await intentGeneral.launch();
      }
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required DateTime scheduledDate,
    int minutesBefore = 30,
  }) async {
    final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledDate, tz.local);
    final tz.TZDateTime notificationTime = tzScheduled.subtract(Duration(minutes: minutesBefore));

    debugPrint("Current time (local): ${tz.TZDateTime.now(tz.local)}");
    debugPrint("Target notification time: $notificationTime");

    if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
      debugPrint("Notification time is in the past.");
      return;
    }

    try {
      await _notifications.zonedSchedule(
        id,
        "Task Reminder",
        title,
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
            importance: Importance.max,
            priority: Priority.high,
            fullScreenIntent: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
      debugPrint("Notification scheduled EXACTLY");
    } catch (e) {
      debugPrint("Exact failed, using inexact: $e");
      await _notifications.zonedSchedule(
        id,
        "Task Reminder",
        title,
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Reminders',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> showInstantNotification(String title) async {
    await _notifications.show(
      0,
      "Instant Test",
      title,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_channel',
          'Tests',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
}
