import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_str.dart';
import 'package:todo_firebase/views/tasks/widgets/list/task_widget.dart';

import '../form/edit_task.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

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
          if (docs.isEmpty || docs.any((doc) {
            final data = doc.data();
            if (data is Map<String, dynamic>) {
              return data['title'] == '__dummy_task__';
            }
            return false;
          })) {
            return const Center(child: const Text(CustomStr.noTaskYet));
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
                  ScaffoldMessenger.of(context).showSnackBar(
                    //todo Unhandled Exception : Looking up a deactivated widget's ancestor is unsafe.
                    //todo At this point the state of the
                    const SnackBar(content: Text(CustomStr.deletedTask)),
                  );
                },
                onMarkedComplete: () async {
                  task.isCompleted = !task.isCompleted;
                  await FirebaseFirestore.instance.collection('tasks').doc(docs[index].id).update({'isCompleted': task.isCompleted});
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