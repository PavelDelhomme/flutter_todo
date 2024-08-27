import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/services/notification_service.dart';
import 'package:todo_firebase/views/tasks/components/task_app_bar.dart';
import 'package:todo_firebase/models/task.dart';
import '../../services/task_service.dart';
import 'forms/task_form.dart';

class TaskView extends StatefulWidget {
  final TextEditingController taskControllerForTitle;
  final TextEditingController taskControllerForSubtitle;
  final Task? task;

  const TaskView({
    super.key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    required this.task,
  });

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  DateTime? startDate;
  DateTime? endDate;
  String priorityLevel = 'Neutre';

  @override
  void initState() {
    super.initState();
    startDate = widget.task?.startDate ?? DateTime.now();
    endDate = widget.task?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    priorityLevel = widget.task?.priorityLevel ?? 'Neutre';
    if (widget.task != null) {
      widget.taskControllerForTitle.text = widget.task!.title;
      widget.taskControllerForSubtitle.text = widget.task!.subtitle;
    }
  }

  void _onStartDateSelected(DateTime selectedDate) {
    setState(() {
      startDate = selectedDate;
    });
  }

  void _onEndDateSelected(DateTime selectedDate) {
    setState(() {
      endDate = selectedDate;
    });
  }

  void _onPrioritySelected(String? selectedPriority) {
    setState(() {
      priorityLevel = selectedPriority!;
    });
  }

  void _saveTask() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      _showErrorDialog('Error', 'You must be logged in to save tasks.');
      return;
    }

    if (widget.taskControllerForTitle.text.isNotEmpty &&
        widget.taskControllerForSubtitle.text.isNotEmpty) {
      try {
        Task task = widget.task ?? Task(
          title: widget.taskControllerForTitle.text,
          subtitle: widget.taskControllerForSubtitle.text,
          startDate: startDate ?? DateTime.now(),
          endDate: endDate ?? DateTime.now().add(const Duration(hours: 1)),
          priorityLevel: priorityLevel,
          userId: userId,
          isCompleted: widget.task?.isCompleted ?? false,
        );

        if (widget.task != null) {
          await taskService.updateTask(task);
        } else {
          await taskService.addTask(task);
        }

        // Plannification des notifications avec notificationsService
        await notificationService.scheduleNotification(
          id: task.id.hashCode,
          title: '${task.title} à démarrer',
          body: "\"${task.title}\" doit commencer bientôt (${task.startDate})",
          scheduledDate: task.startDate,
        );

        await notificationService.scheduleNotification(
          id: task.id.hashCode + 1,
          title: '${task.title} à venir',
          body: "\"${task.title}\" commence dans 10 minutes.",
          scheduledDate: task.startDate.subtract(const Duration(minutes: 10)),
        );

        Navigator.of(context).pop();
      } catch (e) {
        _showErrorDialog('Error', 'An error occurred: $e');
      }
    } else {
      _showErrorDialog('Invalid Input', 'Please complete all fields.');
    }
  }


  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  dynamic deleteTask() async {
    if (widget.task != null) {
      await taskService.deleteTask(widget.task!.id);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Task')),
      body: SingleChildScrollView(
        child: TaskForm(
          taskControllerForTitle: widget.taskControllerForTitle,
          taskControllerForSubtitle: widget.taskControllerForSubtitle,
          initialStartDate: startDate,
          initialEndDate: endDate,
          initialPriorityLevel: priorityLevel,
          onStartDateSelected: _onStartDateSelected,
          onEndDateSelected: _onEndDateSelected,
          onPrioritySelected: _onPrioritySelected,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveTask,
        child: const Icon(Icons.save),
      ),
    );
  }
}