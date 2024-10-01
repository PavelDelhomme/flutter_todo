import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:todo_firebase/services/auth_service.dart';
import 'package:todo_firebase/views/authentication/connexion_view.dart';
import 'package:todo_firebase/views/home/home_view.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  final _secureStorage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    User? currentUser = _authService.currentUser;
    if (currentUser != null) {
      // Vérifier si l'utilisateur existe encore dans Firestore
      FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots()
          .listen((snapshot) {
        if (!snapshot.exists) {
          log('Utilisateur supprimé de la base de données, déconnexion.');
          _authService.signOut();
          _clearLocalCache(); // Supprimer les données locales
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const ConnexionView()),
          );
        }
      });
    }
  }

  Future<void> _clearLocalCache() async {
    await _secureStorage.deleteAll(); // Supprimer toutes les données de stockage sécurisé
  }

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
