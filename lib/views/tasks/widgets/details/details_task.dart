import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/services/service_locator.dart';

import '../../../../models/task.dart';
import '../../../../services/task_service.dart';
import '../form/edit_task.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  TaskDetailsScreenState createState() => TaskDetailsScreenState();
}

class TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Future<Task?> _fetchTaskData() async {
    return await serviceLocator<TaskService>().getTaskById(widget.taskId);
  }

  String formatDateTime(DateTime? dateTime) {
    return dateTime != null ? DateFormat('yyyy-MM-dd – HH:mm').format(dateTime) : 'No reminder set';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail de la tâche"),
      ),
      body: FutureBuilder<Task?>(
        future: _fetchTaskData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Erreur lors du chargement des détails"));
          }

          Task task = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  task.subtitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Date début : ${formatDateTime(task.startDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Echéance : ${formatDateTime(task.endDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      task.isCompleted ? 'Status: Complète' : 'Status: Incomplète',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: task.isCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                    Checkbox(
                      value: task.isCompleted,
                      onChanged: (bool? value) async {
                        setState(() {
                          task.isCompleted = value ?? false;
                        });

                      await serviceLocator<TaskService>().markAsCompleted(widget.taskId);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Tâche marquée comme complète')),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      task.notes,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final updatedTask = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(taskId: widget.taskId),
            ),
          );

          // Recharger les données si la tâche a été mise à jour
          if (updatedTask != null) {
            setState(() {}); // Force un rebuild pour recharger les données
          }
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit),
      ),
    );
  }
}