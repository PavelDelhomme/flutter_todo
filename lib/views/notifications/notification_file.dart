import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void initializeNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
  InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

void scheduleNotification(Task task) async {
  await flutterLocalNotificationsPlugin.zonedSchedule(
    task.id.hashCode,
    'Rappel de tâche',
    task.title,
    tz.TZDateTime.from(task.reminder!, tz.local),
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'task_channel_id',
        'Task Reminders',
        channelDescription: 'Channel for task reminders',
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
    UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
  );
}
