import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskTimeAndDate extends StatelessWidget {
  final DateTime time;
  final DateTime date;
  final bool isCompleted;

  const TaskTimeAndDate({
    Key? key,
    required this.time,
    required this.date,
    required this.isCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10, top: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              DateFormat('hh:mm a').format(time),
              style: TextStyle(fontSize: 14, color: isCompleted ? Colors.white : Colors.grey),
            ),
            Text(
              DateFormat.yMMMEd().format(date),
              style: TextStyle(fontSize: 12, color: isCompleted ? Colors.white : Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
