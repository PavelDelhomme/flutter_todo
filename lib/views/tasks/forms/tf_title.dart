import 'package:flutter/material.dart';

class TaskFieldTitle extends StatelessWidget {
  final TextEditingController controller;

  const TaskFieldTitle({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListTile(
        title: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.black),
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.title, color: Colors.grey),
            border: InputBorder.none,
            hintText: 'Titre de la tâche',
          ),
          onFieldSubmitted: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      ),
    );
  }
}
