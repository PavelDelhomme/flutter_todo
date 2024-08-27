import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_colors.dart';
import 'package:todo_firebase/views/tasks/widgets/task_details/task_detail_view.dart';

class TaskWidget extends StatelessWidget {
  final Task task;
  final VoidCallback onDismissed;
  final VoidCallback onMarkedComplete;
  final List<Task> tasks;

  const TaskWidget({
    super.key,
    required this.task,
    required this.onDismissed,
    required this.onMarkedComplete,
    required this.tasks,
  });

  // Helper to format date
  String formatDateTime(DateTime? dateTime) {
    return dateTime != null ? DateFormat('yyyy-MM-dd – HH:mm').format(dateTime) : 'No reminder set';
  }

  // Helper to determine task status color
  Color _getTaskColor() {
    if (task.isCompleted) {
      return Colors.green.withOpacity(0.6); // Completed tasks
    } else if (task.endDate.isBefore(DateTime.now())) {
      return Colors.red.withOpacity(0.6); // Overdue tasks
    } else {
      return Colors.yellow.withOpacity(0.6); // Ongoing tasks
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TaskDetailView(task: task),
          ),
        );
      },
      child: Dismissible(
        key: Key(task.id),
        background: Container(color: Colors.red),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            tasks.removeWhere((element) => element.id == task.id);
            onDismissed();
          } else if (direction == DismissDirection.startToEnd) {
            onMarkedComplete();
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
                decoration: BoxDecoration(
                  color: task.isCompleted ? Colors.green : Colors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 0.8),
                ),
                child: const Icon(Icons.check, color: Colors.white),
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
