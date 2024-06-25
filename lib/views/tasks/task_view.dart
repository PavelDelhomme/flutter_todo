import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:todo_firebase/views/tasks/components/task_app_bar.dart';
import 'package:todo_firebase/models/task.dart';
import '../../services/notification_service.dart';
import '../../services/task_service.dart';
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
  DateTime? startDate;
  DateTime? endDate;
  DateTime? reminder;
  String priorityLevel = 'Neutre';

  @override
  void initState() {
    super.initState();
    startDate = widget.task?.startDate ?? DateTime.now();
    endDate = widget.task?.endDate ?? DateTime.now().add(const Duration(hours: 1));
    priorityLevel = widget.task?.priorityLevel ?? 'Neutre';
    reminder = widget.task?.reminder;
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
    if (widget.taskControllerForTitle.text.isNotEmpty &&
        widget.taskControllerForSubtitle.text.isNotEmpty) {
      try {
        if (widget.task != null) {
          widget.task?.title = widget.taskControllerForTitle.text;
          widget.task?.subtitle = widget.taskControllerForSubtitle.text;
          widget.task?.startDate = startDate ?? widget.task!.startDate;
          widget.task?.endDate = endDate ?? widget.task!.endDate;
          widget.task?.priorityLevel = priorityLevel;
          widget.task?.reminder = reminder;
          widget.task?.userId = FirebaseAuth.instance.currentUser!.uid;
          taskService.updateTask(widget.task!).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Tâche mise à jour avec succès.")),
            );
          });
        } else {
          var task = Task.create(
            title: widget.taskControllerForTitle.text,
            subtitle: widget.taskControllerForSubtitle.text,
            startDate: startDate ?? DateTime.now(),
            endDate: endDate ?? DateTime.now().add(const Duration(hours: 1)),
            priorityLevel: priorityLevel,
            reminder: reminder,
            userId: FirebaseAuth.instance.currentUser!.uid,
          );
          taskService.addTask(task).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tâche ajoutée avec succès.')),
            );
          });
        }

        if (reminder != null) {
          notificationService.scheduleReminderNotification(
            id: widget.task?.id.hashCode ?? DateTime.now().hashCode,
            title: widget.taskControllerForTitle.text,
            body: 'Rappel pour ${widget.taskControllerForTitle.text}',
            reminderDate: reminder!,
          );
        }

        Navigator.of(context).pop();
      } catch (error) {
        _showErrorDialog('Error', 'Une erreur est survenue pendant l\'enregistrement de la tâche.');
      }
    } else {
      _showErrorDialog('Oops', 'Veuillez remplir tous les champs.');
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
            onPressed: () {
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
                    initialStartDate: startDate,
                    initialEndDate: endDate,
                    initialPriorityLevel: priorityLevel,
                    initialReminder: reminder,
                    onStartDateSelected: _onStartDateSelected,
                    onEndDateSelected: _onEndDateSelected,
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
