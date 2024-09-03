import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CustomSpeedDial extends StatelessWidget {
  final List<SpeedDialChild> children;

  const CustomSpeedDial({
    Key? key,
    required this.children,
  }) : super(key: key);

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