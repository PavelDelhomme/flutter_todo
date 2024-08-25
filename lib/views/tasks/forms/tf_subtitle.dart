import 'package:flutter/material.dart';
import 'package:todo_firebase/utils/custom_str.dart';

class TaskFieldSubtitle extends StatelessWidget {
  final TextEditingController controller;

  const TaskFieldSubtitle({
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
            prefixIcon: Icon(Icons.bookmark_border, color: Colors.grey),
            border: InputBorder.none,
            hintText: CustomStr.addNote,
          ),
          onFieldSubmitted: (value) {
            FocusManager.instance.primaryFocus?.unfocus();
          },
        ),
      ),
    );
  }
}
