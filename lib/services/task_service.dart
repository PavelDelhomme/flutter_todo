import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference userSettingsCollection = FirebaseFirestore.instance.collection('userSettings');

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

      DocumentSnapshot userSettingsDoc = await userSettingsCollection.doc(user.uid).get();
      Map<String, dynamic> userSettings = userSettingsDoc.data() as Map<String, dynamic>;
      int reminderTime = userSettings['reminderTime'] ?? 10;

      // Planifier la notification de démarrage
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Rappel : ${task.title}",
        body: "Votre tâche \"${task.title}\" commence bientôt.",
        taskDate: task.startDate,
        typeNotification: 'start',
        reminderTime: reminderTime,
      );

      // Vérifier si la tâche est déjà en retard
      DateTime now = DateTime.now();
      if (task.endDate.isBefore(now) && !task.isCompleted) {
        await notificationService.scheduleOverdueNotification(
          id: task.id.hashCode + 1,
          title: "Tâche en retard : ${task.title}",
          body: "Votre tâche \"${task.title}\" est en retard.",
        );
      }
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  Future<void> updateTask(Task task) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      if (task.userId != user.uid) {
        throw Exception("User does not have permission to update this task.");
      }

      await notificationService.cancelNotification(task.id.hashCode);
      await notificationService.cancelNotification(task.id.hashCode + 1);

      await taskCollection.doc(task.id).update(task.toMap());
      log("Task updated with id: ${task.id}");

      DocumentSnapshot userSettingsDoc = await userSettingsCollection.doc(user.uid).get();
      Map<String, dynamic> userSettings = userSettingsDoc.data() as Map<String, dynamic>;
      int reminderTime = userSettings['reminderTime'] ?? 10;

      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Mise à jour : ${task.title}",
        body: "Votre tâche \"${task.title}\" a été mise à jour.",
        taskDate: task.startDate,
        typeNotification: "update",
        reminderTime: reminderTime,
      );

      DateTime now = DateTime.now();
      if (task.endDate.isBefore(now) && !task.isCompleted) {
        await notificationService.scheduleOverdueNotification(
          id: task.id.hashCode + 1,
          title: "Tâche en retard : ${task.title}",
          body: "Votre tâche \"${task.title}\" est en retard.",
        );
      }
    } catch (e) {
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


  Future<void> markAsCompleted(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not authenticated or found");
      }

      DocumentSnapshot documentSnapshot = await taskCollection.doc(id).get();

      if (!documentSnapshot.exists) {
        throw Exception("Task doesn't exist");
      }

      /*
      Map<String, dynamic> taskData = documentSnapshot.data() as Map<String, dynamic>;

      if (taskData['userId'] != user.uid) {
        throw Exception("User does not have permission to complete this task");
      }

      await notificationService.cancelNotification(id.hashCode);
      await notificationService.cancelNotification(id.hashCode + 1); // Rappel

      await taskCollection.doc(id).update({"isCompleted": true});
      log("Task ${taskData['id']} marked as completed successfully");
       */
      await taskCollection.doc(id).update({"isCompleted": true});
      log("Task ${id} marked as completed");
    } catch (e) {
      log("Errror marking task as completed : $e");
      throw Exception("Failed to mark task as completed: $e");
    }
  }

  Future<void> markAsNotCompleted(String id) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      DocumentSnapshot documentSnapshot = await taskCollection.doc(id).get();

      if (!documentSnapshot.exists) {
        throw Exception("Task doesn't exist");
      }

      Map<String, dynamic> taskData = documentSnapshot.data() as Map<String, dynamic>;

      if (taskData['userId'] != user.uid) {
        throw Exception("User does not have permission to update this task");
      }

      // Annuler les notifications si besoin (si des notifications doivent être réactivées pour une tâche non terminée)
      await taskCollection.doc(id).update({"isCompleted": false});
      log("Task ${taskData['id']} marked as not completed");

      // Reprogrammer la notifications
      DocumentSnapshot userSettingsDoc = await userSettingsCollection.doc(user.uid).get();
      Map<String, dynamic> userSettings = userSettingsDoc.data() as Map<String, dynamic>;
      int reminderTime = userSettings['reminderTime'] ?? 10;

      // Reprogrammation des notifications si la tâche n'est pas terminée
      DateTime startDate = (taskData['startDate'] as Timestamp).toDate();
      await notificationService.scheduleNotification(
        id: id.hashCode,
        title: "Rappel : ${taskData['title']}",
        body: "Votre tâche \"${taskData['title']}\" commence bientôt.",
        taskDate: startDate,
        typeNotification: 'start',
        reminderTime: reminderTime,
      );
      log("Task ${taskData['id']} marked as not completed and notifications rescheduled.");
    } catch (e) {
      log("Error marking task as not completed: $e");
      throw Exception("Failed to mark task as not completed: $e");
    }
  }

  Future<void> checkAndHandleOverdueTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final tasksSnapshot = await taskCollection.where('userId', isEqualTo: user.uid).get();
      DateTime now = DateTime.now();

      for (var taskDoc in tasksSnapshot.docs) {
        Task task = Task.fromMap(taskDoc.data() as Map<String, dynamic>);

        if (task.endDate.isBefore(now) && !task.isCompleted) {
          // Tâche en retard et non terminée

          await notificationService.cancelNotification(task.id.hashCode);
          await notificationService.cancelNotification(task.id.hashCode + 1);

          await notificationService.scheduleOverdueNotification(
            id: task.id.hashCode + 2,
            title: "Tâche en retard : ${task.title}",
            body: "Votre tâche \"${task.title}\" est en retard.",
          );

          log("Tâche ${task.title} est en retard. Notification envoyée.");
        }
      }
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
            log("task_service.dart task in taskCollection : $taskCollection");
        return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } else {
      return Stream.value([]); // Stream vide si non authentifié
    }
  }
}

final TaskService taskService = TaskService();