import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'task_service.dart';

final GetIt serviceLocator = GetIt.instance;

void setupServiceLocator() {
  // Enregistrer les services
  serviceLocator.registerLazySingleton<AuthService>(() => AuthService());
  serviceLocator.registerLazySingleton<NotificationService>(() => NotificationService());
  serviceLocator.registerLazySingleton<TaskService>(() => TaskService());

  // Enregistrer FirebaseAuth et FirebaseFirestore
  serviceLocator.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  serviceLocator.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
}