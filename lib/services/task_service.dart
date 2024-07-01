import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../services/notification_service.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
  final CollectionReference userCollection = FirebaseFirestore.instance.collection('users');
  final CollectionReference categoryCollection = FirebaseFirestore.instance.collection('categories');

  Future<void> addTask(Task task) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      task.userId = user.uid;
      log('Adding task for user: ${user.uid} with data: ${task.toMap()}');
      try {
        await taskCollection.doc(task.id).set(task.toMap());
        log('Task added successfully');
        await _scheduleTaskNotifications(task);
      } catch (e) {
        log('Error adding task: $e');
      }
    } else {
      throw Exception("User not authenticated");
    }
  }

  Future<void> updateTask(Task task) async {
    log("TaskService started and updateTask called for task id: ${task.id}");
    try {
      await taskCollection.doc(task.id).update(task.toMap());
      log('Task updated successfully');
      await _scheduleTaskNotifications(task);
    } catch (e) {
      log('Error updating task: $e');
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
        log('Fetched tasks for user: ${user.uid}');
        return snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList();
      });
    } else {
      throw Exception("User not authenticated");
    }
  }

  Stream<List<Category>> getCategories() {
    return categoryCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Category.fromMap(data);
      }).toList();
    });
  }

  Future<void> addCategory(Category category) async {
    try {
      await categoryCollection.doc(category.id).set(category.toMap());
      log('Category added successfully');
    } catch (e) {
      log('Error adding category: $e');
    }
  }

  Future<void> updateCategory(Category category) async {
    try {
      await categoryCollection.doc(category.id).update(category.toMap());
      log('Category updated successfully');
    } catch (e) {
      log('Error updating category: $e');
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await categoryCollection.doc(id).delete();
      log('Category deleted successfully');
    } catch (e) {
      log('Error deleting category: $e');
    }
  }

  Future<void> backupTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final tasks = await taskCollection.where('userId', isEqualTo: user.uid).get();
        List<Map<String, dynamic>> tasksData = tasks.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
        await userCollection.doc(user.uid).set({'tasks': tasksData});
        log('Tasks backed up successfully');
      } catch (e) {
        log('Error backing up tasks: $e');
      }
    } else {
      throw Exception("User not authenticated");
    }
  }

  Future<void> restoreTasks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final userDoc = await userCollection.doc(user.uid).get();
        if (userDoc.exists) {
          List<dynamic> tasksData = userDoc.get('tasks');
          for (var taskData in tasksData) {
            Task task = Task.fromMap(taskData as Map<String, dynamic>);
            await taskCollection.doc(task.id).set(task.toMap());
          }
          log('Tasks restored successfully');
        }
      } catch (e) {
        log('Error restoring tasks: $e');
      }
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
