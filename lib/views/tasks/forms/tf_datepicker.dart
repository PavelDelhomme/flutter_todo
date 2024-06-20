import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';

class TaskFieldDatePicker extends StatelessWidget {
  final DateTime? date;
  final Function(DateTime) onDateSelected;
  final Function(DateTime?) showDateAsDateTime;
  final Function(DateTime?) showDate;

  const TaskFieldDatePicker({
    Key? key,
    required this.date,
    required this.onDateSelected,
    required this.showDateAsDateTime,
    required this.showDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        DatePickerBdaya.showDatePicker(
          context,
          showTitleActions: true,
          minTime: DateTime.now(),
          maxTime: DateTime(2030, 3, 5),
          onChanged: (_) {},
          onConfirm: onDateSelected,
          currentTime: showDateAsDateTime(date),
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
              child: Text('Date', style: textTheme.titleMedium),
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
                  showDate(date),
                  style: textTheme.bodyLarge,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
