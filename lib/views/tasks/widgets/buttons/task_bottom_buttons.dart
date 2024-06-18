import 'package:flutter/material.dart';
import 'package:todo_firebase/utils/custom_colors.dart';
import 'package:todo_firebase/utils/custom_str.dart';

class TaskBottomButtons extends StatelessWidget {
  final bool isTaskAlreadyExist;
  final VoidCallback onDelete;
  final VoidCallback onSave;

  const TaskBottomButtons({
    Key? key,
    required this.isTaskAlreadyExist,
    required this.onDelete,
    required this.onSave,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (isTaskAlreadyExist) // Afficher le bouton de suppression uniquement si la tâche existe
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                height: 55,
                decoration: BoxDecoration(
                    border: Border.all(color: CustomColors.primaryColor, width: 2),
                    borderRadius: BorderRadius.circular(15)),
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  onPressed: onDelete,
                  color: Colors.white,
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.close,
                        color: CustomColors.primaryColor,
                      ),
                      SizedBox(width: 5),
                      Text(
                        CustomStr.deleteTask,
                        style: TextStyle(color: CustomColors.primaryColor),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              height: 55,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                onPressed: onSave,
                color: CustomColors.primaryColor,
                child: Text(
                  isTaskAlreadyExist
                      ? CustomStr.updateTaskString // Modifier le texte du bouton selon le contexte
                      : CustomStr.addTaskString,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
