import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';

class TaskFieldTimePicker extends StatelessWidget {
  final DateTime? time;
  final Function(DateTime) onTimeSelected;
  final Function(DateTime?) showTimeAsDateTime;
  final Function(DateTime?) showTime;

  const TaskFieldTimePicker({
    Key? key,
    required this.time,
    required this.onTimeSelected,
    required this.showTimeAsDateTime,
    required this.showTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () {
        DatePickerBdaya.showTimePicker(
          context,
          showTitleActions: true,
          showSecondsColumn: false,
          onChanged: (_) {},
          onConfirm: onTimeSelected,
          currentTime: showTimeAsDateTime(time),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 20, 20, 10),
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
              child: Text('Heure', style: textTheme.titleMedium),
            ),
            Expanded(child: Container()),
            Container(
              margin: const EdgeInsets.only(right: 10),
              width: 80,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade100,
              ),
              child: Center(
                child: Text(
                  showTime(time),
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
