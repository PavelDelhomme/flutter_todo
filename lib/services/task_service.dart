import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/services/service_locator.dart';
import '../models/task.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    // Récupérer l'utilisateur actuel
    final User? user = serviceLocator<FirebaseAuth>().currentUser;

    _checkUserAuthenticated(user);
    // Assigner l'UID de l'utilisateur à la tâche
    task.userId = user!.uid;
    // Enregistrement de la tâche dans Firestore
    await taskCollection.doc(task.id).set(task.toMap());

    // Programmation des notifications lors de la création de la tâche
    await serviceLocator<NotificationService>().scheduleFutureNotifications(
        [task], await serviceLocator<NotificationService>().getUserNotificationSettings(user.uid)
    );
    log("Tâche ajoutée et notifications mise à jour.");
  }

  Future<void> updateTask(Task task) async {
    final User? user = serviceLocator<FirebaseAuth>().currentUser;

    _checkUserAuthenticated(user);

    // Annulation des anciennes notifications
    await serviceLocator<NotificationService>().cancelTaskNotifications(task);

    // Mise à jour de la tâche
    await taskCollection.doc(task.id).update(task.toMap());

    // Programmation des nouvelles notifications
    await serviceLocator<NotificationService>().scheduleFutureNotifications(
      [task], await serviceLocator<NotificationService>().getUserNotificationSettings(user!.uid)
    );

    log("Task updated and notifications rescheduled.");
  }

  Future<void> deleteTask(String id) async {
    await serviceLocator<NotificationService>().cancelNotification(id.hashCode);
    await serviceLocator<NotificationService>().cancelNotification(id.hashCode + 1);
    await taskCollection.doc(id).delete();
    log("Task deleted and notifications canceled");
  }

  Future<void> markAsCompleted(String id) async {
    await taskCollection.doc(id).update({"isCompleted": true});
    await serviceLocator<NotificationService>().cancelNotification(id.hashCode);
    await serviceLocator<NotificationService>().cancelNotification(id.hashCode + 1);
    log("Task marked as completed and notifications canceled");
  }

  Stream<List<Task>> getTasks() {
    final User? user = serviceLocator<FirebaseAuth>().currentUser;

    if (user == null) {
      log("Erreur : L'utilisateur n'est pas authentifié.");
      return Stream.value([]);
    }

    return taskCollection
        .where('userId', isEqualTo: user.uid)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
      List<Task> tasks = snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();

      return tasks.where((task) => task.title != '__dummy_task__').toList();
    });
  }

  // Nouvelle méthode pour récupérer une tâche par ID
  Future<Task?> getTaskById(String taskId) async {
    final doc = await taskCollection.doc(taskId).get();
    if (doc.exists) {
      return Task.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }

  Future<void> createDummyTaskForNewUser(String userId) async {
    // Vérifie si la tâche fictive existe déjà
    final querySnapshot = await taskCollection
        .where('userId', isEqualTo: userId)
        .where('title', isEqualTo: '__dummy_task__')
        .get();

    if (querySnapshot.docs.isEmpty) {
      // Création de la tâche fictive si elle n'existe pas déjà
      final dummyTask = Task(
        id: taskCollection.doc().id,
        userId: userId,
        title: '__dummy_task__',
        subtitle: '',
        notes: '',
        priorityLevel: "Neutre",
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(hours: 1)),
        isCompleted: false,
      );

      await taskCollection.doc(dummyTask.id).set(dummyTask.toMap());
      log("Tâche ficitve ajoutée pour l'utilisateur $userId, aucune tâche fictive ajoutée.");
    }
  }

  Future<void> _checkUserAuthenticated(User? user) async {
    if (user == null) {
      log("task_service : Erreur: l'utilisateur n'est pas authentifié.");
      throw FirebaseAuthException(
          code: "USER_NOT_AUTHENTICATED",
          message: "L'utilisateur n'est pas authentifié."
      );
    }
  }
}

final TaskService taskService = TaskService();