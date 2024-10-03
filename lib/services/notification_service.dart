import 'dart:developer';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';

import '../models/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final InitializationSettings initializationSettings = const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  NotificationService() {
    tz.initializeTimeZones();
  }

  Future<void> initialize() async {
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      var status = await Permission.notification.status;
      if (!status.isGranted) {
        status = await Permission.notification.request();
      }

      // Permissions exact alarm pour Android 12+
      if (defaultTargetPlatform == TargetPlatform.android && (Platform.version.startsWith("12") || Platform.version.startsWith("13"))) {
        var alarmStatus = await Permission.scheduleExactAlarm.status;
        if (!alarmStatus.isGranted) {
          alarmStatus = await Permission.scheduleExactAlarm.request();
        }
      }
      log("Notification permissions requested and granted");
    }
  }

  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
    log("Notification with id $id canceled");
  }

  Future<void> cancelTaskNotifications(Task task) async {
    await cancelNotification(task.id.hashCode); // Cancel start notification
    await cancelNotification(task.id.hashCode + 1); // Cancel reminder notification
  }

  Future<void> cancelNotificationsForTasks(List<Task> tasks) async {
    for (var task in tasks) {
      await cancelTaskNotifications(task);
    }
  }


  Future<Map<String, dynamic>> getUserNotificationSettings(String userId) async {
    final doc = await FirebaseFirestore.instance.collection("userSettings").doc(userId).get();
    if (doc.exists) {
      return doc.data()!;
    }
    return {'reminderEnabled': false, 'reminderTime': 10};
  }

  // Plannification de notifications (start, reminder, overdue)
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime taskDate,
    required String typeNotification, // type 'reminder', 'start' ou 'overdue'
    required int reminderTime,
  }) async {
    final scheduledTZDateTime = tz.TZDateTime.from(
      typeNotification == 'reminder' ? taskDate.subtract(Duration(minutes: reminderTime)) : taskDate,
      tz.local,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTZDateTime,
      const NotificationDetails(
        android: AndroidNotificationDetails('task_channel', 'Task Notifications'),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    log("Notification $typeNotification scheduled for task at $taskDate");
  }

  // Plannification des notifications futures pour une liste de tâches
  Future<void> scheduleFutureNotifications(List<Task> tasks, Map<String, dynamic> userSettings) async {
    DateTime now = DateTime.now();
    for (var task in tasks) {
      if (!task.isCompleted && task.startDate.isAfter(now)) {
        int reminderTime = userSettings['reminderTime'] ?? 10;
        await scheduleNotification(
          id: task.id.hashCode,
          title: "Démarrage de ${task.title}",
          body: "${task.title} commence maintenant.",
          taskDate: task.startDate,
          typeNotification: 'start',
          reminderTime: reminderTime,
        );

        if (userSettings['reminderEnabled'] == true) {
          await scheduleNotification(
            id: task.id.hashCode + 1,
            title: "Rappel : ${task.title}",
            body: "${task.title} commence bientôt.",
            taskDate: task.startDate,
            typeNotification: 'reminder',
            reminderTime: reminderTime,
          );
        }
      }
    }
  }

  // Mise à jour des notifications pour un utilisateur
  Future<void> updateNotificationsForUser(String userId) async {
    final userSettings = await getUserNotificationSettings(userId);

    final taskSnapshot = await FirebaseFirestore.instance.collection('tasks').where('userId', isEqualTo: userId).get();
    List<Task> tasks = taskSnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();

    await cancelNotificationsForTasks(tasks); // Annulation des anciennes notifications
    await scheduleFutureNotifications(tasks, userSettings); // Plannification des nouvelles notifications
  }

  // Mise à jours des notifications selon les paramètres utilisateur
  Future<void> updateNotifications(Map<String, dynamic> userSettings) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await updateNotificationsForUser(user.uid);
    }
    log("Notifications mises à jour avec succès.");
  }

  // Affichage immédiat d'une notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'task_reminder',
      'Task Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidDetails);
    await _flutterLocalNotificationsPlugin.show(id, title, body, platformChannelSpecifics);
    log("Notification shown: $title - $body");
  }
}

final NotificationService notificationService = NotificationService();