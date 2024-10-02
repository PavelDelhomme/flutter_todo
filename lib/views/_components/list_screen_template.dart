import 'package:flutter/material.dart';

class ListScreenTemplate extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;

  const ListScreenTemplate({
    super.key,
    required this.child,
    required this.title,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      floatingActionButton: floatingActionButton,
    );
  }
}