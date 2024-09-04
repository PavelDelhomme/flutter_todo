import 'dart:developer';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings;

  NotificationService()
      : initializationSettings = const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  Future<void> initialize() async {
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    tz.initializeTimeZones();
    log("NotificationService initialized");

    await _requestPermissions();
  }


  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
        if (!status.isGranted) {
          throw Exception('Notification permissions not granted');
        }
      }

      // Permissions exact alarm pour Android 12+
      if (defaultTargetPlatform == TargetPlatform.android && (Platform.version.startsWith("12") || Platform.version.startsWith("13"))) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          alarmStatus = await Permission.scheduleExactAlarm.request();
          if (!alarmStatus.isGranted) {
            throw Exception('Exact alarm permissions not granted');
          }
        }
      }

      log("Notification permissions requested and granted");
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    log("Notification with id $id canceled");
  }


  Future<Map<String, dynamic>> _getUserNotificationSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance.collection('userSettings').doc(user.uid).get();
      log("userSettings dans _getUserNotificationSettings : ${doc.data()}");
      if (doc.exists) {
        return doc.data()!;
      }
    }
    return {
      'reminderEnabled': false,
      'reminderTime': 10, // Valeur par défaut si les paramètres n'existent pas
    };
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime taskDate,
  }) async {
    final userSettings = await _getUserNotificationSettings();
    log("Contenu userSettings : ${userSettings}");

    if (userSettings['reminderEnabled'] == true) {
      log("reminder in userSettings : ${userSettings['reminderTime']}");
      log("reminder in userSettings as int : ${userSettings['reminderTime'] as int}");
      log("taskDate : ${taskDate}");
      log("reminderDate for this task : ${taskDate.subtract(Duration(minutes: userSettings['reminderTime'] as int))}");
      log("reminderDate for this task with userSettings without int : ${taskDate.subtract(Duration(minutes: userSettings['reminderTime']))}");

      //final reminderTime = userSettings['reminderTime'] as int;

      //final reminderDate = taskDate.subtract(Duration(minutes: reminderTime));

      final scheduledTZDateTime = tz.TZDateTime.from(taskDate, tz.local);
      log("Scheduling notification: $title at $scheduledTZDateTime");

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
      ).then((value) => log("Notification scheduled successfully: $title at $scheduledTZDateTime"))
          .catchError((error) {
        log("Error scheduling notification: $error");
      });
    } else {
      log("Reminders are disabled; no notification will be scheduled.");
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
    log("Notification shown: $title - $body");
  }
}

final NotificationService notificationService = NotificationService();