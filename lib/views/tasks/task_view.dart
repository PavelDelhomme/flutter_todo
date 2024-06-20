import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_firebase/views/tasks/components/task_app_bar.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_str.dart';

import '../../services/notification_service.dart';
import 'forms/task_form.dart';

class TaskView extends StatefulWidget {
  final TextEditingController taskControllerForTitle;
  final TextEditingController taskControllerForSubtitle;
  final Task? task;

  const TaskView({
    Key? key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    required this.task,
  }) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  var title;
  var subtitle;
  DateTime? time;
  DateTime? date;
  DateTime? reminder;
  String priorityLevel = 'Neutre';

  @override
  void initState() {
    super.initState();
    time = widget.task?.createdAtTime ?? DateTime.now().add(const Duration(hours: 1));
    date = widget.task?.createdAtDate ?? DateTime.now();
    priorityLevel = widget.task?.priorityLevel ?? 'Neutre';
    reminder = widget.task?.reminder;
    if (widget.task != null) {
      widget.taskControllerForTitle.text = widget.task!.title;
      widget.taskControllerForSubtitle.text = widget.task!.subtitle;
    }
  }

  void _onTimeSelected(DateTime selectedTime) {
    setState(() {
      time = selectedTime;
    });
  }

  void _onDateSelected(DateTime selectedDate) {
    setState(() {
      date = selectedDate;
    });
  }

  void _onReminderSelected(DateTime selectedReminder) {
    setState(() {
      reminder = selectedReminder;
    });
  }

  void _onPrioritySelected(String? selectedPriority) {
    setState(() {
      priorityLevel = selectedPriority!;
    });
  }

  void _saveTask() {
    final taskBox = Hive.box<Task>('tasks');

    if (widget.taskControllerForTitle.text.isNotEmpty &&
        widget.taskControllerForSubtitle.text.isNotEmpty) {
      try {
        if (widget.task != null) {
          widget.task?.title = widget.taskControllerForTitle.text;
          widget.task?.subtitle = widget.taskControllerForSubtitle.text;
          widget.task?.createdAtTime = time ?? widget.task!.createdAtTime;
          widget.task?.createdAtDate = date ?? widget.task!.createdAtDate;
          widget.task?.priorityLevel = priorityLevel;
          widget.task?.reminder = reminder;
          widget.task?.save();
        } else {
          var task = Task.create(
            title: widget.taskControllerForTitle.text,
            createdAtTime: time ?? DateTime.now(),
            createdAtDate: date ?? DateTime.now(),
            subtitle: widget.taskControllerForSubtitle.text,
            priorityLevel: priorityLevel,
            reminder: reminder,
          );
          taskBox.add(task);
        }

        if (reminder != null) {
          notificationService.scheduleReminderNotification(
            id: widget.task?.id.hashCode ?? DateTime.now().hashCode,
            title: widget.taskControllerForTitle.text,
            body: 'Rappel pour ${widget.taskControllerForTitle.text}',
            reminderDate: reminder!,
          );
        }

        if (date != null) {
          notificationService.scheduleDeadlineNotification(
            id: widget.task?.id.hashCode ?? DateTime.now().hashCode,
            title: widget.taskControllerForTitle.text,
            body: 'La date d\'échéance de ${widget.taskControllerForTitle.text} est aujourd\'hui.',
            deadlineDate: date!,
          );
        }

        Navigator.of(context).pop();
      } catch (error) {
        _showErrorDialog('Error', 'Une erreur est survenue pendant l\'enregistrement de la tâche.');
      }
    } else {
      _showErrorDialog('Oops', 'Veuillez remplir tout les champs.');
    }
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () {
            Navigator.of(ctx).pop();
          },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Supprime une tâche
  dynamic deleteTask() {
    widget.task?.delete();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: TaskAppBar(isTaskAlreadyExist: widget.task != null),
        body: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  TaskForm(
                    taskControllerForTitle: widget.taskControllerForTitle,
                    taskControllerForSubtitle: widget.taskControllerForSubtitle,
                    initialTime: time,
                    initialDate: date,
                    initialPriorityLevel: priorityLevel,
                    initialReminder: reminder,
                    onTimeSelected: _onTimeSelected,
                    onDateSelected: _onDateSelected,
                    onReminderSelected: _onReminderSelected,
                    onPrioritySelected: _onPrioritySelected,
                  ),
                  ElevatedButton(
                    onPressed: _saveTask,
                    child: const Text("Sauvegarder"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
