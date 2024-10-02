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

/*import 'dart:developer';
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
    _restoreUserSession(); // Restaurer la session utilisateur si possible
    _checkUserStatus(); // Vérification de l'état de l'utilisateur
  }

  Future<void> _restoreUserSession() async {
    try {
      final email = await _secureStorage.read(key: "userEmail");
      final password = await _secureStorage.read(key: "userPassword");

      log("auth_wrapper.dart : _restoreUserSession : email récupérer depuis _secureStorage : $email");
      log("auth_wrapper.dart : _restoreUserSession : password récupérer depuis _secureStorage : $password");

      if (email != null && password != null) {
        log(
            "auth_wrapper.dart : _restoreUserSession : email & le password ne sont pas nul");
        await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password);
        log("Session restaurée avec succès");
      } else {
        log("auth_wrapper.dart : _restoreUserSession : Aucun identifiant trouvé dans FlutterSecureStorage.");
      }
    } catch (e) {
      log("Erreur lors de la restauration de la session : $e");
    }
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
*/