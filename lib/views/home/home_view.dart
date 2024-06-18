import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
//import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_str.dart';
import 'package:todo_firebase/views/tasks/task_view.dart';
import 'package:todo_firebase/views/settings/settings_view.dart'; // Import for settings view
import 'widget/task_widget.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(CustomStr.mainTitle),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Accueil'),
              onTap: () {
                Navigator.pop(context); // Close the drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Paramètres'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsView()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              onTap: () {
                // Navigate to About Page
              },
            ),
          ],
        ),
      ),
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}
