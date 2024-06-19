import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_firebase/views/notifications/notification_file.dart';
import 'package:todo_firebase/views/tasks/components/task_app_bar.dart';
import 'package:todo_firebase/views/tasks/widgets/forms/tf.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_str.dart';

import '../../services/notification_service.dart';

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
    if (widget.task != null) {
      widget.taskControllerForTitle.text = widget.task!.title;
      widget.taskControllerForSubtitle.text = widget.task!.subtitle;
      time = widget.task!.createdAtTime;
      date = widget.task!.createdAtDate;
      priorityLevel = widget.task!.priorityLevel;
      reminder = widget.task!.reminder;
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

  /// Vérifie si une tâche existe déjà
  bool isTaskAlreadyExistBool() {
    return widget.task != null;
  }

  void _saveTask() {
    final taskBox = Hive.box<Task>('tasks');

    if (widget.taskControllerForTitle.text.isNotEmpty &&
        widget.taskControllerForSubtitle.text.isNotEmpty) {
      try {
        if (widget.task != null) {
          widget.task?.title = title ?? widget.task!.title;
          widget.task?.subtitle = subtitle ?? widget.task!.subtitle;
          widget.task?.createdAtTime = time ?? widget.task!.createdAtTime;
          widget.task?.createdAtDate = date ?? widget.task!.createdAtDate;
          widget.task?.priorityLevel = priorityLevel;
          widget.task?.reminder = reminder;
          widget.task?.save();
        } else {
          var task = Task.create(
            title: title!,
            createdAtTime: time!,
            createdAtDate: date!,
            subtitle: subtitle!,
            priorityLevel: priorityLevel,
            reminder: reminder,
          );
          taskBox.add(task);
        }

        if (reminder != null) {
          notificationService.scheduleReminderNotification(
            id: widget.task?.id.hashCode ?? DateTime.now().hashCode,
            title: widget.taskControllerForTitle.text,
            body: 'Reminder for ${widget.taskControllerForTitle.text}',
            reminderDate: reminder!,
          );
        }

        if (date != null) {
          notificationService.scheduleDeadlineNotification(
            id: widget.task?.id.hashCode ?? DateTime.now().hashCode,
            title: widget.taskControllerForTitle.text,
            body: 'The deadline for ${widget.taskControllerForTitle.text} is today.',
            deadlineDate: date!,
          );
        }

        Navigator.of(context).pop();
      } catch (error) {
        _showErrorDialog('Error', 'An error occurred while saving the task.');
      }
    } else {
      _showErrorDialog('Oops', 'Please fill in all the fields.');
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

  /// Met à jour une tâche existante ou en crée une nouvelle
  void isTaskAlreadyExistUpdateTask() {
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
          widget.task?.reminder = reminder;  // Set the reminder field
          widget.task?.save();
          if (reminder != null) {
            scheduleNotification(widget.task!);
          }
        } else {
          var task = Task.create(
            title: widget.taskControllerForTitle.text,
            createdAtTime: time ?? DateTime.now(),
            createdAtDate: date ?? DateTime.now(),
            subtitle: widget.taskControllerForSubtitle.text,
            priorityLevel: priorityLevel,
            reminder: reminder,  // Set the reminder field
          );
          taskBox.add(task);
          if (reminder != null) {
            scheduleNotification(task);
          }
        }
        Navigator.of(context).pop();
      } catch (error) {
        nothingEnterOnUpdateTaskMode(context);
      }
    } else {
      emptyFieldsWarning(context);
    }
  }

  /// Affiche un avertissement si les champs sont vides
  void emptyFieldsWarning(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(CustomStr.oopsMsg),
        content: const Text("Please fill in all the fields"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  /// Affiche un avertissement si rien n'est entré en mode mise à jour
  void nothingEnterOnUpdateTaskMode(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(CustomStr.oopsMsg),
        content: const Text("Nothing entered to update"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text("OK"),
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
        appBar: TaskAppBar(isTaskAlreadyExist: isTaskAlreadyExistBool()),
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
                    child: const Text("Save Task"),
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
