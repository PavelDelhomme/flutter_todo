import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    // Récupérer l'utilisateur actuel
    final User? user = FirebaseAuth.instance.currentUser;



    if (user == null) {
      log("task_service : Erreur: l'utilisateur n'est pas authentifié.");
      throw FirebaseAuthException(
        code: "USER_NOT_AUTHENTICATED",
        message: "L'utilisateur n'est pas authentifié."
      );
    }
    // Assigner l'UID de l'utilisateur à la tâche
    task.userId = user.uid;

    // Enregistrement de la tâche dans Firestore
    await taskCollection.doc(task.id).set(task.toMap());

    // Mise a jour des notifications pour la nouvelle tâche
    await notificationService.updateNotificationsForUser(user.uid);
    log("Tâche ajoutée et notifications mise à jour.");
  }

  Future<void> updateTask(Task task) async {
    final User? user = FirebaseAuth.instance.currentUser;
    await taskCollection.doc(task.id).update(task.toMap());

    // Mise à jours des notifications
    await notificationService.updateNotificationsForUser(user!.uid);
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
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      log("Erreur : L'utilisateur n'est pas authentifié.");
      return Stream.value([]);
    }

    return taskCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
    });
  }
}

final TaskService taskService = TaskService();