import 'package:flutter/material.dart';

class AddTaskFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AddTaskFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}