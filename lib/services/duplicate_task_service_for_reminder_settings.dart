import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }
      log("Adding task for user: ${user.uid}");

      task.userId = user.uid;

      await taskCollection.doc(task.id).set(task.toMap());
      log("Task added with id: ${task.id}");

      // Planifier la notification de démarrage de la tâche
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Démarrage de ${task.title}",
        body: "Votre tâche \"${task.title}\" débute maintenant.",
        taskDate: task.startDate,
      );
      /*
      // Plannification de la notification de rappel basé sur les paramètres utilisateur
      final userSettings = await notificationService.getUserNotificationSettings();
      if (userSettings['reminderEnabled'] == true) {
        await notificationService.scheduleNotification(
          id: task.id.hashCode+1,
          title: "Rappel"
        )
      }
      */
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }


  Future<void> updateTask(Task task) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      log("user in updateTask in task_service : $user");
      log("user.uid in updateTask in task_service : ${user?.uid}");

      if (user == null) {
        log("task_service : updateTask : user == null");
        throw Exception("User not authenticated");
      }

      if (task.userId != user.uid) {
        log("task_service : updateTask : task.userId != user.uid");
        throw Exception("User does not have permission to update this task. It's not their task.");
      }

      // Récupérer le document de Firestore
      DocumentSnapshot documentSnapshot = await taskCollection.doc(task.id).get();

      if (!documentSnapshot.exists) {
        log("task_service : updateTask : Task with id ${task.id} does not exist in Firestore.");
        throw Exception("Task does not exist");
      }

      log("task_service.dart : userId in task_service : ${user.uid}");
      log("task_service.dart : task data before update: ${documentSnapshot.data()}");

      // Annulation de l'ancienne notification
      await notificationService.cancelNotification(task.id.hashCode);
      log("Notification canceled for task id: ${task.id.hashCode}");

      // Mise à jour de la tâche dans Firestore
      await taskCollection.doc(task.id).update(task.toMap());
      log("task_service updating task with taskCollection.doc(task.id).update(task.toMap())");

      // Reprogrammation de la notification avec la nouvelle date
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Mise à jour: ${task.title}",
        body: "Votre tâche \"${task.title}\" a été mise à jour.",
        taskDate: task.startDate,
      );
      log("Notification scheduled for updated task with new start date: ${task.startDate}");

    } catch (e) {
      log("Error updating task : $e");
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
      throw Exception("Failed to delete task: $e");
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
        log("task_service.dart task in taskCollection : ${taskCollection}");
        return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } else {
      return Stream.value([]); // Stream vide si non authentifié
    }
  }
}

final TaskService taskService = TaskService();