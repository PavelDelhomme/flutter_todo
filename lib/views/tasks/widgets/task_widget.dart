import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_colors.dart';
import 'package:todo_firebase/views/tasks/widgets/task_detail_view.dart';

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

  @override
  Widget build(BuildContext context) {
    final isExpired = task.createdAtDate.isBefore(DateTime.now());
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
          if (direction == DismissDirection.startToEnd) {
            onMarkedComplete();
          } else {
            onDismissed();
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: task.isCompleted
                ? CustomColors.primaryColor.withOpacity(0.6)
                : isExpired
                  ? Colors.red.withOpacity(0.6)
                  : Colors.white,
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
              onTap: () {
                task.isCompleted = !task.isCompleted;
                task.save();
              },
              child: Container(
                decoration: BoxDecoration(
                  color: task.isCompleted ? CustomColors.primaryColor : Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey, width: 0.8),
                ),
                child: const Icon(Icons.check, color: Colors.white),
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(bottom: 5, top: 3),
              child: Text(
                task.title,
                style: TextStyle(
                  color: task.isCompleted ? CustomColors.primaryColor : Colors.black,
                  fontWeight: FontWeight.w500,
                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                ),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.subtitle,
                  style: TextStyle(
                    color: task.isCompleted ? CustomColors.primaryColor : const Color.fromRGBO(0, 0, 0, 1),
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
                          DateFormat('hh:mm a').format(task.createdAtTime),
                          style: TextStyle(fontSize: 14, color: task.isCompleted ? Colors.white : Colors.white60),
                        ),
                        Text(
                          DateFormat.yMMMEd().format(task.createdAtDate),
                          style: TextStyle(fontSize: 12, color: task.isCompleted ? Colors.white : Colors.white70),
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