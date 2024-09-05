import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/models/task.dart';

import '../details/details_task.dart';
import '../form/edit_task.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onDismissed;
  final VoidCallback onMarkedComplete;

  const TaskWidget({
    Key? key,
    required this.task,
    required this.onDismissed,
    required this.onMarkedComplete,
  }) : super(key: key);

  String formatDateTime(DateTime? dateTime) {
    return dateTime != null ? DateFormat('yyyy-MM-dd – HH:mm').format(dateTime) : 'Pas de rappel';
  }

  Color _getTaskColor() {
    if (task.isCompleted) {
      return Colors.green.withOpacity(0.6);
    } else if (task.endDate.isBefore(DateTime.now())) {
      return Colors.red.withOpacity(0.6);
    } else {
      return Colors.yellow.withOpacity(0.6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailsScreen(taskId: task.id),
          ),
        );
      },
      child: Dismissible(
        key: Key(task.id),
        background: Container(
          color: Colors.green,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.edit, color: Colors.white),
        ),
        secondaryBackground: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text("Confirmation"),
                  content: const Text("Voulez-vous vraiment supprimer cette tâche ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text("Annuler"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text("Supprimer"),
                    ),
                  ],
                );
              },
            );
          } else if (direction == DismissDirection.startToEnd) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => EditTaskScreen(taskId: task.id),
              ),
            );
            return false;
          }
          return false;
        },
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            onDismissed();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getTaskColor(),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 4),
                blurRadius: 10,
              ),
            ],
          ),
          child: ListTile(
            leading: GestureDetector(
              onTap: onMarkedComplete,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: task.isCompleted ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 0.8),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 3),
              child: Text(
                task.title,
                style: TextStyle(
                  color: task.isCompleted ? Colors.grey : Colors.black,
                  fontWeight: FontWeight.w500,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  fontStyle: task.isCompleted ? FontStyle.italic : FontStyle.normal,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.subtitle,
                  style: TextStyle(
                    color: task.isCompleted ? Colors.grey : Colors.black,
                    fontWeight: FontWeight.w300,
                    decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Début : ${formatDateTime(task.startDate)}',
                          style: TextStyle(fontSize: 13, color: task.isCompleted ? Colors.grey : Colors.black54),
                        ),
                        Text(
                          'Fin : ${formatDateTime(task.endDate)}',
                          style: TextStyle(fontSize: 12, color: task.isCompleted ? Colors.grey : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
