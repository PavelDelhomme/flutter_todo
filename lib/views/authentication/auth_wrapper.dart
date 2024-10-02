import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/views/authentication/connexion_view.dart';
import 'package:todo_firebase/views/home/home_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User?>();

    if (firebaseUser != null) {
      return const HomeView();
    } else {
      return const ConnexionView();
    }
  }
}