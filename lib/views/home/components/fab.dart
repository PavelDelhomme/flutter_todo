import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:todo_firebase/utils/custom_colors.dart';

class Fab extends StatelessWidget {
  const Fab({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        // Nous allons naviguer vers la vue Task en cliquant sur ce bouton
        log("FabButtonClicked");
      },
      child: Material(
        borderRadius: BorderRadius.circular(15),
        elevation: 20,
        child: Container(
          width: 70,
          height: 70,

          decoration: BoxDecoration(
              color: CustomColors.primaryColor,
              borderRadius: BorderRadius.circular(15)
          ),
          child: const Center(
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
