import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/services/task_service.dart';
import 'package:todo_firebase/utils/custom_str.dart';
import 'package:todo_firebase/views/tasks/widgets/list/task_widget.dart';

import '../form/edit_task.dart';

class TasksList extends StatefulWidget {
  const TasksList({super.key});

  @override
  State<TasksList> createState() => _TasksListState();
}

class _TasksListState extends State<TasksList> {
  String formatDateTime(DateTime? dateTime) {
    return dateTime != null ? DateFormat('EEE d MMM yyyy à HH:mm').format(dateTime) : CustomStr.noReminder;
  }

  Future<void> _deleteTask(String id) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text(CustomStr.errorLoadingDatas));
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text(CustomStr.noTaskYet));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var taskData = docs[index].data() as Map<String, dynamic>;
              Task task = Task.fromMap(taskData);

              return TaskWidget(
                task: task,
                onDismissed: () async {
                  await _deleteTask(docs[index].id);

                  // Utiliser WidgetsBinding pour vérifier si le widget est monté avant d'afficher le SnackBar
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) { // Vérifie si le widget est toujours monté
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Tâche supprimée.")),
                      );
                    }
                  });
                },
                onMarkedComplete: () async {
                  if (!task.isCompleted) {
                    await taskService.markAsCompleted(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Tâche marquée comme terminée.")),
                    );
                  } else {
                    await taskService.markAsNotCompleted(task.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Cette tâche est déjà terminée.")),
                    );
                  }
                },
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_task),
            label: CustomStr.addNewTask,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditTaskScreen(taskId: ''),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
