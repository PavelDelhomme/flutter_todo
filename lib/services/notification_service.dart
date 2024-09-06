import 'dart:developer';
import 'dart:io' show Platform;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:permission_handler/permission_handler.dart';
import 'package:todo_firebase/views/tasks/widgets/details/details_task.dart';

import '../main.dart';
import '../models/task.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings initializationSettingsAndroid = const AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings;

  NotificationService()
      : initializationSettings = const InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );

  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          log('Notification payload: ${response.payload}');
          _handleNotificationClick(response.payload!);
        }
      },
    );

    tz.initializeTimeZones();
    log("NotificationService initialized");

    await _requestPermissions();
  }


  void _handleNotificationClick(String payload) {
    navigatorKey.currentState?.push(
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(taskId: payload),
      ),
    );
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

  Future<void> cancelAllNotificationsForUser() async {
    final tasks = await FirebaseFirestore.instance.collection('tasks')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    for (var task in tasks.docs) {
      final taskIdHash = task['id'].hashCode;
      await cancelNotification(taskIdHash); // Annule démarrage
      await cancelNotification(taskIdHash + 1); // Annule rappel
    }
  }

  Future<void> cancelFuturesNotifications(List<Task> tasks) async {
    DateTime now = DateTime.now();

    for (var task in tasks) {
      if (task.startDate.isAfter(now)) {
        await notificationService.cancelNotification(task.id.hashCode);
        log("notification_service : Notification future annulée pour la tâche: ${task.id} - ${task.title}");
      }
    }
  }

  Future<void> cancelFutureNotifications(List<Task> tasks) async {
    DateTime now = DateTime.now();

    for (var task in tasks) {
      if (task.startDate.isAfter(now)) {
        // Annule uniquement les notifications dont la date de début est dans le futur
        await notificationService.cancelNotification(task.id.hashCode);
        log("Notification future annulée pour la tâche : ${task.title}");
      } else {
        log("Notification pour la tâche ${task.title} est déjà passé, aucune annulation.");
      }
    }
  }

  Future<void> cancelUserFutureNotifications(String userId) async {
    final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
    QuerySnapshot querySnapshot = await taskCollection.where('userId', isEqualTo: userId).get();

    List<Task> tasks = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Task.fromMap(data);
    }).toList();

    await cancelFutureNotifications(tasks);
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
    required String typeNotification,
    required int reminderTime,
  }) async {
    final userSettings = await _getUserNotificationSettings();
    log("notification_service : scheduleNotification : Contenu userSettings $userSettings");

    if (userSettings['reminderEnabled'] == true && typeNotification == "reminder") {
      final reminderDate = taskDate.subtract(Duration(minutes: reminderTime));

      // Vérifie que reminderDate est dans le futur
      if (reminderDate.isBefore(DateTime.now())) {
        log("La date du rappel est déjà passée. Aucune notification ne sera programmée.");
        return;  // Ne pas planifier de notification si la date est dans le passé
      }

      log("notification_service : scheduleNotification : Scheduling notification : $title at $reminderDate");

      final scheduledTZDateTime = tz.TZDateTime.from(reminderDate, tz.local);
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_reminder',
            'Task Reminder',
            channelDescription: 'Rappel de tâche',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        payload: id.toString(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      ).then((value) => log("Notification scheduled successfully: $title at $scheduledTZDateTime"))
          .catchError((error) {
        log("Error scheduling notification: $error");
      });
    } else if (typeNotification == "start") {
      final scheduledTZDateTime = tz.TZDateTime.from(taskDate, tz.local);
      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZDateTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'task_start',
            'Task Start',
            channelDescription: 'Démarrage de tâche',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }


  Future<void> scheduleOverdueNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    log("notification_service : scheduleOverdueNotification : Scheduling overdue notification for task: $title");
    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_overdue',
          'Tâche en retard',
          channelDescription: 'Notification de tâche en retard',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
    );
  }
  Future<void> scheduleFutureNotifications(List<Task> tasks, Map<String, dynamic> userSettings) async {
    DateTime now = DateTime.now();

    for (var task in tasks) {
      if (task.startDate.isAfter(now)) {
        int reminderTime = userSettings['reminderTime'] ?? 10;

        await notificationService.scheduleNotification(
          id: task.id.hashCode,
          title: "Rappel : ${task.title}",
          body: "Votre tâche \"${task.title}\" commence bientôt.",
          taskDate: task.startDate,
          typeNotification: "reminder",
          reminderTime: reminderTime,
        );
        log("Notification programmée pour la tâche future : ${task.title}");
      } else {
        log("La tâche ${task.title} est déjà passée, aucune notification programmée.");
      }
    }
  }
  Future<void> updateUserNotifications(String userId) async {
    // Annuler les notifications futures
    await cancelUserFutureNotifications(userId);

    // Récupérer les nouveaux paramètres utilisateur
    DocumentSnapshot userSettingsDoc = await FirebaseFirestore.instance.collection('userSettings').doc(userId).get();
    Map<String, dynamic> userSettings = userSettingsDoc.data() as Map<String, dynamic>;

    // Récupérer toutes les tâches de l'utilisateur
    final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
    QuerySnapshot querySnapshot = await taskCollection.where('userId', isEqualTo: userId).get();

    List<Task> tasks = querySnapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      return Task.fromMap(data);
    }).toList();

    // Programmer les notifications futures avec les nouveaux paramètres
    await scheduleFutureNotifications(tasks, userSettings);
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