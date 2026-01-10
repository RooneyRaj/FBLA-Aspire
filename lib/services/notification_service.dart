import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    // 1. Initialize Timezones
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // 2. Platform settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await _notificationsPlugin.initialize(initializationSettings);

    // 3. Android 14+ Permission Logic
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

      // Request normal notification permission (Android 13+)
      await androidImplementation?.requestNotificationsPermission();

      // Check and request "Exact Alarm" permission (Android 14+)
      // Fix: Method renamed to canScheduleExactNotifications in v19.x
      final bool? canScheduleExact = await androidImplementation?.canScheduleExactNotifications();
      
      if (canScheduleExact == false) {
        // This will open the system "Alarms & Reminders" settings page
        await androidImplementation?.requestExactAlarmsPermission();
      }
    }
  }

  static Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    final notificationTime = scheduledDate.subtract(const Duration(minutes: 15));

    if (notificationTime.isBefore(DateTime.now())) return;

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(notificationTime, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'fbla_reminders',
          'FBLA Event Reminders',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Required for v19: choose how precise the timing should be
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }
}