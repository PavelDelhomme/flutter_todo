import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../form/edit_task.dart';

class TaskDetailsScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  TaskDetailsScreenState createState() => TaskDetailsScreenState();
}

class TaskDetailsScreenState extends State<TaskDetailsScreen> {

  Future<DocumentSnapshot> _fetchTaskData() async {
    return await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).get();
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
      body: FutureBuilder<DocumentSnapshot>(
        future: _fetchTaskData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Erreur lors du chargement des détails"));
          }
          var data = snapshot.data!.data() as Map<String, dynamic>?;
          if (data == null) {
            return const Center(child: Text("Aucune donnée disponible"));
          }

          DateTime startDate = (data['startDate'] as Timestamp).toDate();
          DateTime endDate = (data['endDate'] as Timestamp).toDate();
          bool isCompleted = data['isCompleted'] ?? false;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['title'],
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  data['subtitle'] ?? '',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Date début : ${formatDateTime(startDate)}',
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
                      'Echéance : ${formatDateTime(endDate)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      isCompleted ? 'Status: Complète' : 'Status: Incomplète',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCompleted ? Colors.green : Colors.red,
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: (bool? value) {
                        setState(() {
                          isCompleted = value ?? false;
                        });
                        FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).update({'isCompleted': value});
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      data['notes'] ?? '',
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditTaskScreen(taskId: widget.taskId),
            ),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.edit),
      ),
    );
  }
}