import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_firebase/views/notifications/notification_file.dart';
import 'package:todo_firebase/views/tasks/components/task_app_bar.dart';
import 'package:todo_firebase/views/tasks/widgets/buttons/task_bottom_buttons.dart';
import 'package:todo_firebase/views/tasks/widgets/forms/tf.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/custom_str.dart';

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

  void saveTask() {
    final taskBox = Hive.box<Task>('tasks');

    if (widget.taskControllerForTitle.text.isNotEmpty &&
        widget.taskControllerForSubtitle.text.isNotEmpty) {
      try {
        if (widget.task != null) {
          widget.task!.title = widget.taskControllerForTitle.text;
          widget.task!.subtitle = widget.taskControllerForSubtitle.text;
          widget.task!.createdAtTime = time ?? widget.task!.createdAtTime;
          widget.task!.createdAtDate = date ?? widget.task!.createdAtDate;
          widget.task!.priorityLevel = priorityLevel;
          widget.task!.reminder = reminder;
          widget.task!.save();
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
          scheduleNotification(widget.task!);
        }
        Navigator.of(context).pop();
      } catch (error) {
        showErrorDialog(context, "Nothing entered to update");
      }
    } else {
      showErrorDialog(context, "Please fill in all the fields");
    }
  }

  void showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(CustomStr.oopsMsg),
        content: Text(message),
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

  void deleteTask() {
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
                  ),
                  TaskBottomButtons(
                    isTaskAlreadyExist: widget.task != null,
                    onDelete: deleteTask,
                    onSave: saveTask,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
