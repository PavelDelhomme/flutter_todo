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

      // Planifier la notification
      await notificationService.scheduleNotificationForTask(
        id: task.id.hashCode,
        title: "Rappel : ${task.title}",
        body: "Votre tâche \"${task.title}\" commence bientôt.",
        taskDate: task.startDate,
      );
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      // Annuler l'ancienne notification
      await notificationService.cancelNotification(task.id.hashCode);

      // Mettre à jour la tâche dans Firestore
      await taskCollection.doc(task.id).update(task.toMap());

      // Reprogrammer la notification avec la nouvelle date
      await notificationService.scheduleNotificationForTask(
        id: task.id.hashCode,
        title: "Mise à jour: ${task.title}",
        body: "Votre tâche \"${task.title}\" a été mise à jour.",
        taskDate: task.startDate,
      );
      log("Notification scheduled for ${task.title}");
      log("taskDate: ${task.startDate}");
    } catch (e) {
      log('Error updating task: $e');
      throw Exception("Failed to update task: $e");
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      // Annuler la notification liée à cette tâche avant de la supprimer
      await notificationService.cancelNotification(id.hashCode);

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
}

final TaskService taskService = TaskService();
