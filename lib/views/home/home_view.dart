import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_str.dart';
import 'package:todo_firebase/views/tasks/task_view.dart';
import 'package:todo_firebase/views/home/components/drawer_menu.dart';
import 'package:todo_firebase/views/home/components/fab.dart';
import 'package:todo_firebase/views/home/components/app_bar.dart';
import 'package:todo_firebase/views/tasks/widgets/task_widget.dart';

import '../../services/notification_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  Box<Task> taskBox = Hive.box<Task>("tasks");

  void _navigateToAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskView(
          taskControllerForTitle: TextEditingController(),
          taskControllerForSubtitle: TextEditingController(),
          task: null,
        ),
      ),
    ).then((value) {
      setState(() {}); // Refresh the state when returning from the TaskView
    });
  }

  void _deleteTask(Task task) {
    task.delete();
    setState(() {});
  }

  void _markTaskComplete(Task task) {
    task.isCompleted = !task.isCompleted;
    task.save();
    setState(() {});
  }

  void _testNotification() {
    notificationService.showTestNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(onNotificationPressed: _testNotification),
      drawer: const DrawerMenu(),
      body: ValueListenableBuilder(
        valueListenable: taskBox.listenable(),
        builder: (context, Box<Task> tasks, _) {
          if (tasks.isEmpty) {
            return const Center(
              child: Text(CustomStr.noTaskYet),
            );
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks.getAt(index);
              return TaskWidget(
                task: task!,
                onDismissed: () => _deleteTask(task),
                onMarkedComplete: () => _markTaskComplete(task),
              );
            },
          );
        },
      ),
      floatingActionButton: AddTaskFab(onPressed: _navigateToAddTask),
    );
  }
}
