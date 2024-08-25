import 'package:flutter/material.dart';

class TaskFieldPriority extends StatelessWidget {
  final String priorityLevel;
  final ValueChanged<String?> onPrioritySelected;

  const TaskFieldPriority({
    super.key,
    required this.priorityLevel,
    required this.onPrioritySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.flag, color: Colors.grey),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: priorityLevel,
            items: ['Urgente', 'Neutre'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: onPrioritySelected,
          ),
        ],
      ),
    );
  }
}
