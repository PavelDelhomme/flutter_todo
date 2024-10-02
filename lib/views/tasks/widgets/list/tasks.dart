import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/services/service_locator.dart';
import 'package:todo_firebase/services/task_service.dart';
import 'package:todo_firebase/utils/custom_str.dart';
import 'package:todo_firebase/views/tasks/widgets/list/task_widget.dart';

import '../form/edit_task.dart';

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  String formatDateTime(DateTime? dateTime) {
    return dateTime != null ? DateFormat('EEE d MMM yyyy à HH:mm').format(dateTime) : CustomStr.noReminder;
  }

  Future<void> _deleteTask(String id) async {
    await serviceLocator<TaskService>().deleteTask(id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<List<Task>>(
        stream: serviceLocator<TaskService>().getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text(CustomStr.errorLoadingDatas));
          }

          var tasks = snapshot.data ?? [];

          if (tasks.isEmpty) {
            return const Center(child: Text(CustomStr.noTaskYet));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return TaskWidget(
                task: task,
                onDismissed: () async {
                  await _deleteTask(task.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text(CustomStr.deletedTask)),
                  );
                },
                onMarkedComplete: () async {
                  await serviceLocator<TaskService>().markAsCompleted(task.id);
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