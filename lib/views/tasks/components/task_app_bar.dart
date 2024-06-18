import 'package:flutter/material.dart';

class TaskAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isTaskAlreadyExist;

  const TaskAppBar({
    Key? key,
    required this.isTaskAlreadyExist,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: double.infinity,
      height: 150,
      child: Padding(
        padding: const EdgeInsets.only(top: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 50,
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Text(
                  isTaskAlreadyExist ? 'Modifier tâche' : 'Ajouter tâche',
                  style: textTheme.titleLarge,
                ),
              ),
            ),
            const SizedBox(width: 70), // to balance the back button space
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}
