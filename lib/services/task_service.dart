import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
  final user = FirebaseAuth.instance.currentUser!;

  Future<void> addTask(Task task) async {
    task.userId = user.uid;
    await taskCollection.doc(task.id).set(task.toMap());

    // Mise a jour des notifications pour la nouvelle tâche
    await notificationService.updateNotificationsForUser(user.uid);
    log("Task added and notifications updated.");
  }

  Future<void> updateTask(Task task) async {
    await taskCollection.doc(task.id).update(task.toMap());

    // Mise à jours des notifications
    await notificationService.updateNotificationsForUser(user.uid);
    log("Task updated and notifications rescheduled.");
  }

  Future<void> deleteTask(String id) async {
    await notificationService.cancelNotification(id.hashCode); // Cancel start notification
    await notificationService.cancelNotification(id.hashCode + 1); // Cancel reminder notification
    await taskCollection.doc(id).delete();
    log("Task deleted and notifications canceled");
  }


  Future<void> markAsCompleted(String id) async {
    await taskCollection.doc(id).update({"isCompleted": true});
    await notificationService.cancelNotification(id.hashCode);
    await notificationService.cancelNotification(id.hashCode + 1);
    log("Task marked as completed and notifications canceled");
  }

  Stream<List<Task>> getTasks() {
    try {
      return taskCollection
          .where('userId', isEqualTo: user.uid)
          .orderBy('startDate', descending: true)
          .snapshots()
          .map((snapshot) {
            log("task_service.dart task in taskCollection : $taskCollection");
        return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } catch (e) {
      return Stream.value([]); // Stream vide si non authentifié
    }
  }
}

final TaskService taskService = TaskService();