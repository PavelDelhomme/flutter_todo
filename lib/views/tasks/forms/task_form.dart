import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'tf_subtitle.dart';
import 'tf_title.dart';
import 'tf_priority.dart';

class TaskForm extends StatefulWidget {
  final TextEditingController taskControllerForTitle;
  final TextEditingController taskControllerForSubtitle;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;
  final String initialPriorityLevel;
  final Function(DateTime) onStartDateSelected;
  final Function(DateTime) onEndDateSelected;
  final Function(String?) onPrioritySelected;

  const TaskForm({
    super.key,
    required this.taskControllerForTitle,
    required this.taskControllerForSubtitle,
    this.initialStartDate,
    this.initialEndDate,
    this.initialPriorityLevel = 'Neutre',
    required this.onStartDateSelected,
    required this.onEndDateSelected,
    required this.onPrioritySelected,
  });

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  DateTime? startDate;
  DateTime? endDate;
  late String priorityLevel;

  @override
  void initState() {
    super.initState();
    startDate = widget.initialStartDate ?? DateTime.now();
    endDate = widget.initialStartDate ?? DateTime.now().add(const Duration(hours: 1));
    priorityLevel = widget.initialPriorityLevel;
  }

  String formatDateTime(DateTime? date) {
    return DateFormat('yyyy-MM-dd – HH:mm').format(date ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 500, // Adjust the height accordingly
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
              DatePickerBdaya.showDateTimePicker(
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
                  Text(formatDateTime(startDate), style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              DatePickerBdaya.showDateTimePicker(
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
                  Text(formatDateTime(endDate), style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
