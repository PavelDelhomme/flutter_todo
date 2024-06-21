import 'package:flutter/material.dart';

class TaskSubtitle extends StatelessWidget {
  final String subtitle;
  final bool isCompleted;

  const TaskSubtitle({
    Key? key,
    required this.subtitle,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(
        color: isCompleted ? Colors.green : const Color.fromARGB(255, 164, 164, 164),
        fontWeight: FontWeight.w300,
        decoration: isCompleted ? TextDecoration.lineThrough : null,
      ),
    );
  }
}
