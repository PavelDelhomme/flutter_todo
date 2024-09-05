import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CustomSpeedDial extends StatelessWidget {
  final List<SpeedDialChild> children;

  const CustomSpeedDial({
    super.key,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spaceBetweenChildren: 4,
      children: children,
    );
  }
}