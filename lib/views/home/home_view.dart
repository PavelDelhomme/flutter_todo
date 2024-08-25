import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/services/task_service.dart';
import 'package:todo_firebase/views/authentication/connexion_view.dart';
import 'package:todo_firebase/views/tasks/task_view.dart';
import 'package:todo_firebase/views/home/components/drawer_menu.dart';
import 'package:todo_firebase/views/home/components/fab.dart';
import 'package:todo_firebase/views/home/components/app_bar.dart';
import 'package:todo_firebase/views/tasks/widgets/task_widget.dart';

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
      MaterialPageRoute(builder: (context) => const ConnexionView()),
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
    taskService.deleteTask(task.id).then((_) {
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche supprimée avec succès')),
      );
    });
  }

  void _markTaskComplete(Task task) {
    task.isCompleted = !task.isCompleted;
    taskService.updateTask(task).then((_) {
      setState(() {}); // Refresh the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statut de la tâche mis à jour')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      drawer: DrawerMenu(onSignOut: _signOut),
      body: StreamBuilder<List<Task>>(
        stream: taskService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            log("home_view : snapshot.hasError : Error: ${snapshot.error}");
            return Center(child: Text("Erreur: ${snapshot.error}"));
          }
          final tasks = snapshot.data ?? [];
          log("home_view : tasks content = $tasks");
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
