import 'dart:io' show Platform;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initializationSettings;

  NotificationService()
      : initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  Future<void> initialize() async {
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    await _requestPermissions();
    print("NotificationService initialized");
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      // Notification permissions
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
        if (!status.isGranted) {
          throw Exception('Notification permissions not granted');
        }
      }

      // Exact alarm permissions for Android 12+
      if (defaultTargetPlatform == TargetPlatform.android && Platform.version.startsWith("12") || Platform.version.startsWith("13")) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          alarmStatus = await Permission.scheduleExactAlarm.request();
          if (!alarmStatus.isGranted) {
            throw Exception('Exact alarm permissions not granted');
          }
        }
      }

      print("Notification permissions requested and granted");
    }
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'task_reminder',
      'Task Reminder',
      channelDescription: 'Reminder de tâche',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
    print("Notification shown: $title - $body");
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    print("Scheduling notification: $title at $scheduledDate");

    final scheduledTZDateTime = tz.TZDateTime.from(scheduledDate, tz.local);
    print("Scheduled TZDateTime: $scheduledTZDateTime");

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminder',
          'Task Reminder',
          channelDescription: 'Reminder de tâche',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    ).then((value) => print("Notification scheduled successfully: $title at $scheduledDate"))
        .catchError((error) {
      print("Error scheduling notification: $error");
    });
  }

  Future<void> scheduleMissedReminderNotification({
    required int id,
    required String title,
    required String body,
    required DateTime missedReminderDate,
  }) async {
    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(missedReminderDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'missed_task',
          'Missed Task',
          channelDescription: 'Notification for missed tasks',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    ).then((value) => print("Missed task notification scheduled successfully: $title at $missedReminderDate"))
        .catchError((error) {
      print("Error scheduling missed task notification: $error");
    });
  }
}

final NotificationService notificationService = NotificationService();
