import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:todo_firebase/models/task.dart';
import 'firebase_options.dart';
import 'views/authentication/auth_wrapper.dart';
import 'views/authentication/sign_in_view.dart';
import 'views/home/home_view.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(TaskAdapter());
  await Hive.openBox<Task>('tasks');

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await notificationService.initialize();

  final now = DateTime.now();
  await notificationService.showNotification(
    id: 1,
    title: 'Test Notification',
    body: 'This is a test notification',
  );
  print("Test notification scheduled for ${now.add(Duration(minutes: 1))}");

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
      routes: {
        '/sign-in': (context) => const SignInView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}
