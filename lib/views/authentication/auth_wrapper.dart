import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/views/authentication/connexion_view.dart';
import 'package:todo_firebase/views/home/home_view.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const HomeView();
        }

        return const ConnexionView();
      },
    );
  }
}