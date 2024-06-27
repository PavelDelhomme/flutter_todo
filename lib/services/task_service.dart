import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection =
  FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      task.userId = user.uid;
      await taskCollection.doc(task.id).set(task.toMap());
      await _scheduleTaskNotifications(task);
    } else {
      throw Exception("User not authenticated");
    }
  }

  Future<void> updateTask(Task task) async {
    await taskCollection.doc(task.id).update(task.toMap());
    await _scheduleTaskNotifications(task);
  }

  Future<void> deleteTask(String id) async {
    await taskCollection.doc(id).delete();
  }

  Stream<List<Task>> getTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return taskCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((snapshot) => snapshot.docs
          .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
          .toList());
    } else {
      throw Exception("User not authenticated");
    }
  }

  Future<void> _scheduleTaskNotifications(Task task) async {
    final now = DateTime.now();

    if (task.reminder != null && task.reminder!.isAfter(now)) {
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: 'Rappel de tâche',
        body: 'Il est temps de commencer la tâche "${task.title}".',
        scheduledDate: task.reminder!,
      );
      print('Scheduled reminder notification for task: ${task.title} at ${task.reminder}');
    }

    if (task.startDate.isAfter(now)) {
      await notificationService.scheduleNotification(
        id: task.id.hashCode + 2,
        title: 'Tâche à démarrer',
        body: 'La tâche "${task.title}" doit commencer.',
        scheduledDate: task.startDate,
      );
      print('Scheduled start date notification for task: ${task.title} at ${task.startDate}');
    }

    if (task.endDate.isAfter(now)) {
      await notificationService.scheduleNotification(
        id: task.id.hashCode + 1,
        title: 'Tâche terminée',
        body: 'La tâche "${task.title}" est terminée.',
        scheduledDate: task.endDate,
      );
      print('Scheduled end date notification for task: ${task.title} at ${task.endDate}');
    }

    if (task.endDate.isBefore(now) && !task.isCompleted) {
      await notificationService.scheduleMissedReminderNotification(
        id: task.id.hashCode + 3,
        title: 'Tâche manquée',
        body: 'Vous avez manqué la tâche "${task.title}".',
        missedReminderDate: now.add(const Duration(seconds: 5)),
      );
      print('Scheduled missed task notification for task: ${task.title}');
    }
  }
}

final TaskService taskService = TaskService();
