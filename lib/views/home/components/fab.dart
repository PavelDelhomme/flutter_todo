import 'package:flutter/material.dart';

class AddTaskFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AddTaskFab({Key? key, required this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      child: const Icon(Icons.add),
    );
  }
}
