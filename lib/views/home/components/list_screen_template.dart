import 'package:flutter/material.dart';

class ListScreenTemplate extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const ListScreenTemplate({
    Key? key,
    required this.child,
    required this.title,
    this.floatingActionButton,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}