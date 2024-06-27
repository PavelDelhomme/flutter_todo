import 'dart:developer';
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
    log("TaskService started and updateTask called");
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

    if (task.startDate.isAfter(now)) {
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: 'Tâche à démarrer',
        body: 'La tâche "${task.title}" doit commencer.',
        scheduledDate: task.startDate,
      );
      log('Scheduled start date notification for task: ${task.title} at ${task.startDate}');

      // Ajout d'une notification de pré-reminder 10 minutes avant le début de la tâche
      await notificationService.scheduleNotification(
        id: task.id.hashCode + 1,
        title: 'Tâche à venir',
        body: 'La tâche "${task.title}" va commencer dans 10 minutes.',
        scheduledDate: task.startDate.subtract(const Duration(minutes: 10)),
      );
      log('Scheduled pre-start notification for task: ${task.title} at ${task.startDate.subtract(const Duration(minutes: 10))}');
    }

    if (task.endDate.isAfter(now)) {
      await notificationService.scheduleNotification(
        id: task.id.hashCode + 2,
        title: 'Tâche terminée',
        body: 'La tâche "${task.title}" est terminée.',
        scheduledDate: task.endDate,
      );
      log('Scheduled end date notification for task: ${task.title} at ${task.endDate}');

      await notificationService.scheduleNotification(
        id: task.id.hashCode + 3,
        title: 'Tâche en retard',
        body: 'La tâche "${task.title}" est en retard. Veuillez la terminer.',
        scheduledDate: task.endDate.add(const Duration(minutes: 5)),
      );
      log('Scheduled overdue notification for task: ${task.title} at ${task.endDate.add(const Duration(minutes: 5))}');
    }

    if (task.endDate.isBefore(now) && !task.isCompleted) {
      await notificationService.scheduleMissedReminderNotification(
        id: task.id.hashCode + 4,
        title: 'Tâche manquée',
        body: 'Vous avez manqué la tâche "${task.title}".',
        missedReminderDate: now.add(const Duration(seconds: 5)),
      );
      log('Scheduled missed task notification for task: ${task.title}');
    }
  }
}

final TaskService taskService = TaskService();
