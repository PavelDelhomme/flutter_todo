import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';

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
    endDate = widget.initialEndDate ?? startDate!.add(const Duration(hours: 1));
    priorityLevel = widget.initialPriorityLevel;
  }

  String formatDateTime(DateTime? date) {
    return DateFormat('yyyy-MM-dd – HH:mm').format(date ?? DateTime.now());
  }

  void _onStartDateSelected(DateTime selectedDate) {
    setState(() {
      startDate = selectedDate;
      endDate = selectedDate.add(const Duration(hours: 1));
    });
    widget.onStartDateSelected(selectedDate);
    widget.onEndDateSelected(endDate!);
  }

  void _onEndDateSelected(DateTime selectedDate) {
    if (selectedDate.isAfter(startDate!)) {
      setState(() {
        endDate = selectedDate;
      });
      widget.onEndDateSelected(selectedDate);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La date de fin doit être après la date de début.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 500, // Adjust height as necessary
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: TextFormField(
                controller: widget.taskControllerForTitle,
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
          ),
          const SizedBox(height: 10),
          // Subtitle field
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              title: TextFormField(
                controller: widget.taskControllerForSubtitle,
                style: const TextStyle(color: Colors.black),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.bookmark_border, color: Colors.grey),
                  border: InputBorder.none,
                  hintText: 'Ajouter une note',
                ),
                onFieldSubmitted: (value) {
                  FocusManager.instance.primaryFocus?.unfocus();
                },
              ),
            ),
          ),
          // Priority dropdown
          Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.flag, color: Colors.grey),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: priorityLevel,
                  items: ['Urgente', 'Neutre'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (selectedPriority) {
                    setState(() {
                      priorityLevel = selectedPriority!;
                    });
                    widget.onPrioritySelected(selectedPriority);
                  },
                ),
              ],
            ),
          ),
          // Start date picker
          GestureDetector(
            onTap: () {
              DatePickerBdaya.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(2000, 1, 1),
                maxTime: DateTime(2101, 12, 31),
                onChanged: (_) {},
                onConfirm: _onStartDateSelected,
                currentTime: startDate,
                locale: LocaleType.fr,
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
                  Text('Date de début : ', style: textTheme.titleMedium),
                  Expanded(child: Container()),
                  Text(formatDateTime(startDate), style: textTheme.bodyLarge),
                ],
              ),
            ),
          ),
          // End date picker
          GestureDetector(
            onTap: () {
              DatePickerBdaya.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: startDate, // Ensure end date is after start date
                maxTime: DateTime(2101, 12, 31),
                onChanged: (_) {},
                onConfirm: _onEndDateSelected,
                currentTime: endDate,
                locale: LocaleType.fr,
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
                  Text('Date de fin : ', style: textTheme.titleMedium),
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
