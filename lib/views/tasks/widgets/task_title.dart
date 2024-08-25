import 'package:flutter/material.dart';

class TaskTitle extends StatelessWidget {
  final String title;
  final bool isCompleted;

  const TaskTitle({
    super.key,
    required this.title,
    required this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5, top: 3),
      child: Text(
        title,
        style: TextStyle(
          color: isCompleted ? Colors.green : Colors.black,
          fontWeight: FontWeight.w500,
          decoration: isCompleted ? TextDecoration.lineThrough : null,
        ),
      ),
    );
  }
}
