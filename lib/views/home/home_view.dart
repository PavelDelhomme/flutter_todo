import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/services/task_service.dart';
import 'package:todo_firebase/views/authentication/sign_in_view.dart';
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
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signOut() async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const SignInView()),
    );
  }

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
      setState(() {});
    });
  }

  void _deleteTask(Task task) {
    taskService.deleteTask(task.id);
  }

  void _markTaskComplete(Task task) {
    task.isCompleted = !task.isCompleted;
    taskService.updateTask(task);
  }

  void _testNotification() {
    notificationService.showTestNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: HomeAppBar(onNotificationPressed: _testNotification),
      drawer: DrawerMenu(onSignOut: _signOut),
      body: StreamBuilder<List<Task>>(
        stream: taskService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("home_view : snapshot.hasError : Error: ${snapshot.error}"));
          }
          final tasks = snapshot.data ?? [];
          log("home_view : tasks content = $tasks");
          log("home_view : tasks content = ${tasks.first.title}");
          if (tasks.isEmpty) {
            log("home_view : tasks empty");
            return const Center(
              child: Text("Pas encore de tâches"),
            );
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskWidget(
                task: task,
                //onDismissed: () => _deleteTask(task),
                //onMarkedComplete: () => _markTaskComplete(task),
              );
            },
          );
        },
      ),
      floatingActionButton: AddTaskFab(onPressed: _navigateToAddTask),
    );
  }
}
