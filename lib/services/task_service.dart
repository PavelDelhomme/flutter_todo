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

      // Planifier la notification de démarrage de la tâche
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Rappel : ${task.title}",
        body: "Votre tâche \"${task.title}\" commence bientôt.",
        taskDate: task.startDate,
      );
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }
  /*
  Future<void> updateTask(Task task) async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        throw Exception("User not authenticated");
      }

      if (task.userId != user.uid) {
        throw Exception("User does not have permission to update this task.");
      }

      // Vérifier si le document existe déjà
      DocumentSnapshot docSnapshot = await taskCollection.doc(task.id).get();

      if (!docSnapshot.exists) {
        throw Exception("Task does not exist, cannot update.");
      }

      log("task_service.dart : userId in task_service : ${user.uid}");

      // Annuler l'ancienne notification
      await notificationService.cancelNotification(task.id.hashCode);

      log("task_service task.toMap : ${task.toMap()}");

      // Mettre à jour la tâche dans Firestore
      await taskCollection.doc(task.id).update(task.toMap(excludeId: true));

      log("task_service updating task with taskCollection.doc(task.id).update(task.toMap())");
      log("task_service updating task ${task.toMap()} with task.id ${task.id}");

      // Reprogrammer la notification avec la nouvelle date
      await notificationService.scheduleNotification(
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
  */
  /*
  Future<void> updateTaskByRecreating(Task task) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        log("User not authenticated");
        throw Exception("User not authenticated");
      }

      if (task.userId != user.uid) {
        log("User does not have permission to update this task in updateTaskByRecreating (is not his own)");
        throw Exception("User does not have permission to update this task in updateTaskByRecreating (is not his own)");
      }

      // Annulation de l'ancienne notification
      await notificationService.cancelNotification(task.id.hashCode);

      // Suppression de l'ancienne tâche
      await deleteTask(task.id);

      // Ajout de la nouvelle version de la tâche
      await addTask(task);

      log("Task update successfully by deleting and recreating.");
    } catch (e) {
      log("Error updating task by recreating: $e");
      throw Exception("Failed to update task: $e");
    }
  }
  */

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
        throw Exception("User does not have permission to update this task. It's not his task.");
      }

      DocumentSnapshot documentSnapshot = await taskCollection.doc(task.id).get();

      if (!documentSnapshot.exists) {
        log("task_service : updateTask : documentSnapshot doesn't exists yet");
      }

      log("task_service.dart : userId in task_service : ${user.uid}");

      // Annulation de l'ancienne notification
      await notificationService.cancelNotification(task.id.hashCode);

      log("task_service.dart task.toMap : ${task.toMap()}");

      // Mise a jour de la tâche dans Firestore
      await taskCollection.doc(task.id).update(task.toMap(excludeId: true));

      log("task_service updating task with taskCollection.doc(task.id).update(task.toMap())");

      // Reprogrammation de notification avec la nouvelle date
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Mise à jour: ${task.title}",
        body: "Votre tâche \"${task.title}\" a été mise à jour.",
        taskDate: task.startDate,
      );
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
            log("task_service.dart task in taskCollection : ${taskCollection}");
        return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } else {
      return Stream.value([]); // Stream vide si non authentifié
    }
  }
}

final TaskService taskService = TaskService();