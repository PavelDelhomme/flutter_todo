import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthenticationProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;

  AuthenticationProvider(this.firebaseAuth);

  Stream<User?> get authState => firebaseAuth.authStateChanges();

  Future<void> signIn({required String email, required String password}) async {
    try {
      await firebaseAuth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      debugPrint("Erreur de connexion: ${e.message}");
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(email: email, password: password);
      log("authentication_provider : ${firebaseAuth.currentUser}");
    } on FirebaseAuthException catch (e) {
      log("Erreur d'inscription : ${e.message}");
    }
  }

  Future<void> signOut() async {
    await firebaseAuth.signOut();
  }
}