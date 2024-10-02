import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_firebase/services/service_locator.dart';
import '../models/user.dart';


class AuthService {
  // Anciens fonctionnement des services
  //final FirebaseAuth _auth = FirebaseAuth.instance;
  //final FirebaseFirestore _db = FirebaseFirestore.instance;
  //final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // Service centralisés
  final FirebaseAuth _auth = serviceLocator<FirebaseAuth>();
  final FirebaseFirestore _db = serviceLocator<FirebaseFirestore>();
  final FlutterSecureStorage _secureStorage = serviceLocator<FlutterSecureStorage>();

  // Connexion user
  Future<User?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim()
      );

      log("Connexion réussie pour l'utilisateur : ${userCredential.user?.uid}");

      try {
        await _saveUserCredentials(userCredential.user!, password);
        log("Identifiants sauvegarder avec succès dans FlutterSecureStorage.");
      } catch (e) {
        log("Erreur lors de la sauvegarde des identifiants : $e");
      }

      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      log('Erreur lors de la connexion : ${e.message}');
      rethrow;
    }
  }

  // Inscription user
  Future<User?> signUp(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email.trim(), password: password.trim());

      log("Création du compte réussie. UID : ${userCredential.user?.uid}");

      // Vérification que l'utilisateur est bien créé avant de procéder
      if (userCredential.user == null) {
        throw Exception("Utilisateur non créé correctement.");
      }

      User user = userCredential.user!;
      String userId = user.uid;

      // Créer les documents pour l'utilisateur
      await _createUserData(userId, email);

      // Passer le mot de passe lors de l'enregistrement
      await _saveUserCredentials(user, password);

      log("Création du compte et initialisation réussie pour l'utilisateur avec UID : $userId");

      return user;
    } on FirebaseAuthException catch (e) {
      log("Erreur lors de l'inscription : ${e.message}");
      rethrow;
    } catch (e) {
      log("Erreur inconnue lors de l'inscription : $e");
      rethrow;
    }
  }

  Future<void> _createUserData(String userId, String email) async {
    // Créer le document de l'utilisateur
    UserModel newUser = UserModel(
      id: userId,
      email: email.trim(),
      name: '', // Placeholder
    );

    // Enregistrer dans la collections 'users'
    await _db.collection("users").doc(userId).set(newUser.toMap());

    // Créer les paramètres utilisateur
    await _db.collection('userSettings').doc(userId).set({
      'reminderEnabled': false,
      'reminderTime': 10,
    });

    // Créer une tâche "dummy" pour éviter l'erreur de collection vide
    await _db.collection('tasks').doc().set({
      'userId': userId,
      'title': '__dummy_task__',
      'subtitle': '__dummy__',
      'notes': '__dummy__',
      'priorityLevel': 'Neutre',
      'startDate': DateTime.now(),
      'endDate': DateTime.now(),
      'isCompleted': true,
    });
    log("Tâche dummy créer pour l'utilisateur $userId");
  }

  // Sauvegarde des identifiants utilisateur dans le cache local
  Future<void> _saveUserCredentials(User user, String password) async {
    await _secureStorage.write(key: 'userEmail', value: user.email);
    log("auth_service.dart : _saveUserCredentials : userEmail saved : ${user.email}");
    await _secureStorage.write(key: 'userPassword', value: password);  // Utiliser une variable sécurisée
    log("auth_service.dart : _saveUserCredentials : userPassword saved : $password");
  }

  // Déconnexion
  Future<void> signOut() async {
    await _secureStorage.deleteAll();
    await _auth.signOut();
  }

  // Récupérer l'utilisateur connecté
  User? get currentUser => _auth.currentUser;
}