import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    try {
      await taskCollection.doc(task.id).set(task.toMap());

    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      await taskCollection.doc(task.id).update(task.toMap());
    } catch (e) {
      log('Error updating task: $e');
      throw Exception("Failed to update task: $e");
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await taskCollection.doc(id).delete();
      log('Task deleted successfully');
    } catch (e) {
      log('Error deleting task: $e');
    }
  }

  Future<void> deleteTasksForDeletedUsers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final users = await FirebaseFirestore.instance.collection('users').get();
        final userIds = users.docs.map((doc) => doc.id).toSet();

        final tasks = await taskCollection.get();
        for (var task in tasks.docs) {
          final taskData = task.data();
          if (taskData is Map<String, dynamic>) {
            if (!userIds.contains(taskData['userId'])) {
              await task.reference.delete();
              log('Deleted task for user that no longer exists: ${task.id}');
            }
          }
        }
      } catch (e) {
        log('Error deleting tasks for deleted users: $e');
      }
    } else {
      throw Exception("User not authenticated");
    }
  }
  Stream<List<Task>> getTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return taskCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } else {
      return Stream.value([]); // Stream vide si non authentifié
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
