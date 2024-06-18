import 'package:flutter/material.dart';
import 'package:todo_firebase/utils/custom_str.dart';

class TaskFormTopText extends StatelessWidget {
  final bool isTaskAlreadyExist;

  const TaskFormTopText({
    Key? key,
    required this.isTaskAlreadyExist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
          Text(
            isTaskAlreadyExist ? 'Modifier tâche' : 'Ajouter tâche',
            style: textTheme.titleLarge,
          ),
          const SizedBox(
            width: 70,
            child: Divider(
              thickness: 2,
            ),
          ),
        ],
      ),
    );
  }
}
