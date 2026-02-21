import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();
  static const MethodChannel _channel =
  MethodChannel('com.mototek.portal/timezone');

  static Future<void> initialize() async {
    // ❌ IMPORTANT: Skip everything for Web
    if (kIsWeb) {
      print("🌐 Web detected → using Firebase Push Notifications instead");
      return;
    }

    tz.initializeTimeZones();

    try {
      if (Platform.isAndroid) {
        final String? timeZoneName =
        await _channel.invokeMethod('getTimezone');

        if (timeZoneName != null) {
          tz.setLocalLocation(tz.getLocation(timeZoneName));
        } else {
          tz.setLocalLocation(tz.getLocation("Asia/Kolkata"));
        }
      }
    } catch (e) {
      tz.setLocalLocation(tz.UTC);
    }

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);

    final androidImplementation = _notifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required DateTime scheduledDate,
    int minutesBefore = 30,
  }) async {
    // ❌ Skip local scheduling on web
    if (kIsWeb) return;

    final tz.TZDateTime tzScheduled =
    tz.TZDateTime.from(scheduledDate, tz.local);
    final tz.TZDateTime notificationTime =
    tzScheduled.subtract(Duration(minutes: minutesBefore));

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
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
      UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}