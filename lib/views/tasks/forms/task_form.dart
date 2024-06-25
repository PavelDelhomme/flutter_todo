import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'tf_datepicker.dart';
import 'tf_subtitle.dart';
import 'tf_time_picker.dart';
import 'tf_title.dart';
import 'tf_priority.dart';

class TaskForm extends StatefulWidget {
  final TextEditingController taskControllerForTitle;
  final TextEditingController taskControllerForSubtitle;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String initialPriorityLevel;
  final DateTime? initialReminder;
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;
  final Function(DateTime) onReminderSelected;
  final Function(String?) onPrioritySelected;

  const TaskForm({
    Key? key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    this.initialStartDate,
    this.initialEndDate,
    this.initialPriorityLevel = 'Neutre',
    this.initialReminder,
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onReminderSelected,
    required this.onPrioritySelected,
  }) : super(key: key);

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  DateTime? startDate;
  DateTime? endDate;
  DateTime? reminder;
  late String priorityLevel;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate ?? DateTime.now();
    endDate = widget.initialEndDate ?? DateTime.now().add(const Duration(hours: 1));
    reminder = widget.initialReminder;
    priorityLevel = widget.initialPriorityLevel;
  }

  String formatDate(DateTime? date) {
    return DateFormat.yMMMEd().format(date ?? DateTime.now());
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
          GestureDetector(
            onTap: () {
              DatePickerBdaya.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(2101, 12, 31),
                onChanged: (_) {},
                onConfirm: (selectedDate) {
                  setState(() {
                    startDate = selectedDate;
                  });
                  widget.onStartDateSelected(selectedDate);
                },
                currentTime: startDate,
                locale: LocaleType.en,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text('Start Date: ', style: textTheme.titleMedium),
                  Expanded(child: Container()),
                  Text(formatDate(startDate), style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              DatePickerBdaya.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(2101, 12, 31),
                onChanged: (_) {},
                onConfirm: (selectedDate) {
                  setState(() {
                    endDate = selectedDate;
                  });
                  widget.onEndDateSelected(selectedDate);
                },
                currentTime: endDate,
                locale: LocaleType.en,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text('End Date: ', style: textTheme.titleMedium),
                  Expanded(child: Container()),
                  Text(formatDate(endDate), style: textTheme.bodyLarge),
                ],
              ),
            ),
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
                currentTime: reminder,
              );
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Text('Reminder: ', style: textTheme.titleMedium),
                  Expanded(child: Container()),
                  Text(formatDate(reminder), style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
