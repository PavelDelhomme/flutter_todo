import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/utils/authentication_provider.dart';
import 'package:todo_firebase/views/authentication/connexion_view.dart';
import 'package:todo_firebase/views/home/home_view.dart';
import 'firebase_options.dart';
import 'views/authentication/auth_wrapper.dart';
import 'services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Suppression de la persistance si nécessaire
  //FirebaseFirestore.instance.clearPersistence();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  /*
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  await secureStorage.deleteAll();
   */


  try {
    await notificationService.initialize();
  } catch (e) {
    log('Error initializing notification service: $e');
  }

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthenticationProvider>(
          create: (_) => AuthenticationProvider(FirebaseAuth.instance),
        ),
        StreamProvider<User?>(
          create: (context) => context.read<AuthenticationProvider>().authState,
          initialData: null,
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Todo App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthWrapper(), // Redirection selon l'état de l'utilisateur
        routes: {
          '/sign-in': (context) => const ConnexionView(),
          '/home': (context) => const HomeView(),
        },
      ),
    );
    /*return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
      routes: {
        '/sign-in': (context) => const ConnexionView(),
        '/home': (context) => const HomeView(),
      },
    );*/
  }
}