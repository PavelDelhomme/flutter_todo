import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:todo_firebase/utils/custom_str.dart';
import 'tf_datepicker.dart';
import 'tf_subtitle.dart';
import 'tf_time_picker.dart';
import 'tf_title.dart';
import 'tf_priority.dart';

class TaskForm extends StatefulWidget {
  final TextEditingController taskControllerForTitle;
  final TextEditingController taskControllerForSubtitle;
  final DateTime? initialTime;
  final DateTime? initialDate;
  final String initialPriorityLevel;
  final DateTime? initialReminder;
  final Function(DateTime) onTimeSelected;
  final Function(DateTime) onDateSelected;
  final Function(DateTime) onReminderSelected;
  final Function(String?) onPrioritySelected;

  const TaskForm({
    Key? key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    this.initialTime,
    this.initialDate,
    this.initialPriorityLevel = 'Neutre',
    this.initialReminder,
    required this.onTimeSelected,
    required this.onDateSelected,
    required this.onReminderSelected,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  DateTime? time;
  DateTime? date;
  DateTime? reminder;
  late String priorityLevel;

  @override
  void initState() {
    super.initState();
    time = widget.initialTime ?? DateTime.now().add(const Duration(hours: 1));
    date = widget.initialDate ?? DateTime.now();
    reminder = widget.initialReminder;
    priorityLevel = widget.initialPriorityLevel;
  }

  String showTime(DateTime? time) {
    return DateFormat('hh:mm a').format(time ?? DateTime.now());
  }

  String showDate(DateTime? date) {
    return DateFormat.yMMMEd().format(date ?? DateTime.now());
  }

  DateTime showTimeAsDateTime(DateTime? time) {
    return time ?? DateTime.now();
  }

  DateTime showDateAsDateTime(DateTime? date) {
    return date ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 600,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaskFieldTitle(controller: widget.taskControllerForTitle),
          const SizedBox(height: 10),
          TaskFieldSubtitle(controller: widget.taskControllerForSubtitle),
          TaskFieldPriority(
            priorityLevel: priorityLevel,
            onPrioritySelected: (selectedPriority) {
              setState(() {
                priorityLevel = selectedPriority!;
              });
              widget.onPrioritySelected(selectedPriority);
            },
          ),
          TaskFieldTimePicker(
            time: time,
            onTimeSelected: (selectedTime) {
              setState(() {
                time = selectedTime;
              });
              widget.onTimeSelected(selectedTime);
            },
            showTimeAsDateTime: showTimeAsDateTime,
            showTime: showTime,
          ),
          TaskFieldDatePicker(
            date: date,
            onDateSelected: (selectedDate) {
              setState(() {
                date = selectedDate;
              });
              widget.onDateSelected(selectedDate);
            },
            showDateAsDateTime: showDateAsDateTime,
            showDate: showDate,
          ),
          GestureDetector(
            onTap: () {
              DatePickerBdaya.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: DateTime.now(),
                onChanged: (_) {},
                onConfirm: (selectedReminder) {
                  setState(() {
                    reminder = selectedReminder;
                  });
                  widget.onReminderSelected(selectedReminder);
                },
                currentTime: showDateAsDateTime(reminder),
              );
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 10, 20, 10),
              width: double.infinity,
              height: 55,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: Text('Rappel', style: textTheme.titleMedium),
                  ),
                  Expanded(child: Container()),
                  Container(
                    margin: const EdgeInsets.only(right: 10),
                    width: 140,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade100,
                    ),
                    child: Center(
                      child: Text(
                        showDate(reminder),
                        style: textTheme.bodyLarge,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
