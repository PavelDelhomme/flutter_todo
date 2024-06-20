import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class TaskService {
  final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');

  Future<void> addTask(Task task) async {
    await taskCollection.doc(task.id).set(task.toMap());
  }

  Future<void> updateTask(Task task) async {
    await taskCollection.doc(task.id).update(task.toMap());
  }

  Future<void> deleteTask(String id) async {
    await taskCollection.doc(id).delete();
  }

  Stream<List<Task>> getTasks() {
    final userId = FirebaseAuth.instance.currentUser!.uid;
    return taskCollection.where('userId', isEqualTo: userId).snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>)).toList());
  }
}

final taskService = TaskService();
