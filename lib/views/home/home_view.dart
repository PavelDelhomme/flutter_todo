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

import '../../services/notification_service.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Task> tasks = []; // Stockez les tâches ici

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
      setState(() {}); // Actualise l'interface après l'ajout de la tâche
    });
  }
  void _markTaskComplete(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });

    taskService.updateTask(task).then((_) {
      // Annule les notifications liées à cette tâche
      notificationService.cancelNotification(task.id.hashCode);
      notificationService.cancelNotification(task.id.hashCode + 1); // Pour la notification de rappel

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Statut de la tâche mis à jour')),
      );
    });
  }

  void _deleteTask(Task task) {
    taskService.deleteTask(task.id).then((_) {
      setState(() {
        tasks.removeWhere((element) => element.id == task.id); // Supprime la tâche localement
      });

      // Annule les notifications liées à cette tâche
      notificationService.cancelNotification(task.id.hashCode);
      notificationService.cancelNotification(task.id.hashCode + 1); // Pour la notification de rappel

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tâche supprimée avec succès')),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const HomeAppBar(),
      body: StreamBuilder<List<Task>>(
        stream: taskService.getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            log("Error fetching tasks: ${snapshot.error}");
            return const Center(child: Text("Erreur lors de la récupération des tâches"));
          }
          tasks = snapshot.data ?? [];
          if (tasks.isEmpty) {
            return const Center(child: Text("Pas encore de tâches"));
          }
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return TaskWidget(
                task: task,
                tasks: tasks, // Passe la liste des tâches à TaskWidget
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
