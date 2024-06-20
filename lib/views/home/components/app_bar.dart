import 'package:flutter/material.dart';
import 'package:todo_firebase/utils/custom_str.dart';

class HomeAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onNotificationPressed;

  const HomeAppBar({Key? key, required this.onNotificationPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text(CustomStr.mainTitle),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications),
          onPressed: onNotificationPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
