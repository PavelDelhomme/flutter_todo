import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:todo_firebase/models/task.dart';
import 'package:todo_firebase/services/notification_service.dart';
import 'package:todo_firebase/services/service_locator.dart';
import 'package:todo_firebase/utils/authentication_provider.dart';
import 'package:todo_firebase/views/authentication/connexion_view.dart';
import 'package:todo_firebase/views/home/home_view.dart';
import 'firebase_options.dart';
import 'views/authentication/auth_wrapper.dart';
import 'package:timezone/data/latest.dart' as tz;


Future<void> deleteAllTasks() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  try {
    // Récupérer tous les documents de la collection "tasks"
    QuerySnapshot querySnapshot = await firestore.collection('tasks').get();

    // Supprimer chaque document
    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
      await doc.reference.delete();
    }

  } catch (e) {
    log("Erreur lors de la suppression des tâches : $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Suppression de la persistance si nécessaire
  //FirebaseFirestore.instance.clearPersistence();

  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  // Initialiser les services
  setupServiceLocator();


  // Vérification des notifications et des tâches au démarrage
  await verifyAndUpdateTaskNotifications();
  //await deleteAllTasks();

  runApp(const MainApp());
}

Future<void> verifyAndUpdateTaskNotifications() async {
  final User? user = serviceLocator<FirebaseAuth>().currentUser;
  if (user != null) {
    // Récupérer les paramètres utilisateur
    final userSettings = await serviceLocator<NotificationService>().getUserNotificationSettings(user.uid);

    // Récupérer toutes les tâches de l'utilisateur
    final taskSnapshot = await FirebaseFirestore.instance.collection('tasks').where('userId', isEqualTo: user.uid).get();
    List<Task> tasks = taskSnapshot.docs.map((doc) => Task.fromMap(doc.data())).toList();

    DateTime now = DateTime.now();

    for (var task in tasks) {
      if (!task.isCompleted && task.startDate.isBefore(now) && task.endDate.isAfter(now)) {
        // Tâche en cours et non complétée
        await FirebaseFirestore.instance.collection('tasks').doc(task.id).update({
          'status': 'en retard'
        });
        log("Tâche ${task.title} mise à jour en 'en retard'.");
      }
    }

    // Ne reprogrammer que les notifications des tâches futures
    List<Task> futureTasks = tasks.where((task) => !task.isCompleted && task.startDate.isAfter(now)).toList();
    await serviceLocator<NotificationService>().scheduleFutureNotifications(futureTasks, userSettings);
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
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
  }
}