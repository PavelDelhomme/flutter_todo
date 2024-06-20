import 'package:flutter/material.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/views/tasks/task_view.dart';
import 'package:hive/hive.dart';

class TaskDetailView extends StatefulWidget {
  final Task task;

  const TaskDetailView({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailViewState createState() => _TaskDetailViewState();
}

class _TaskDetailViewState extends State<TaskDetailView> {
  late Task task;

  @override
  void initState() {
    super.initState();
    task = widget.task;
  }

  Future<void> _refreshTask() async {
    final taskBox = Hive.box<Task>('tasks');
    final updatedTask = taskBox.get(task.id);
    if (updatedTask != null) {
      setState(() {
        task = updatedTask;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails de ${task.title}'),
      ),
      body: FutureBuilder(
        future: _refreshTask(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else {
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
                      const Icon(Icons.access_time, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('hh:mm a').format(task.createdAtTime),
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
                        DateFormat.yMMMEd().format(task.createdAtDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    task.isCompleted ? 'Status: Complète' : 'Status: Incomplète',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: task.isCompleted ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskView(
                taskControllerForTitle: TextEditingController(text: task.title),
                taskControllerForSubtitle: TextEditingController(text: task.subtitle),
                task: task,
              ),
            ),
          );
          _refreshTask();
        },
        child: const Icon(Icons.edit),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
