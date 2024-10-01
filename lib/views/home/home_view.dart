import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:todo_firebase/views/home/components/drawer_menu.dart';
import 'package:todo_firebase/views/tasks/widgets/form/edit_task.dart';
import 'package:todo_firebase/views/tasks/widgets/list/tasks.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _currentTitle = 'Tâches';
  Widget _currentScreen = const TasksList();

  void _selectScreen(String title, Widget screen) {
    setState(() {
      _currentTitle = title;
      _currentScreen = screen;
    });
    Navigator.pop(context);
  }

  void _navigateToAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditTaskScreen(taskId: ''),
      ),
    ).then((_) {
      setState(() {
        _currentTitle = 'Tâches';
        _currentScreen = const TasksList();
      }); // Actualise l'interface après l'ajout de la tâche
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initializeUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Erreur lors du chargement des données"));
        }
        return Scaffold(
          appBar: AppBar(title: Text(_currentTitle)),
          drawer: DrawerMenu(onSignOut: _selectScreen),
          body: _currentScreen,
          floatingActionButton: _currentTitle == 'Tâches' ? SpeedDial(
            icon: Icons.add,
            activeIcon: Icons.close,
            spaceBetweenChildren: 4,
            children: [
              SpeedDialChild(
                child: const Icon(Icons.add_task),
                label: 'Ajouter une tâche',
                onTap: _navigateToAddTask,
              ),
            ],
          ) : null,
        );
      },
    );
  }

  Future<void> _initializeUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userDoc = await FirebaseFirestore.instance.collection("userSettings").doc(user.uid).get();
      if (!userDoc.exists) {
        await FirebaseFirestore.instance.collection("userSettings").doc(user.uid).set({
          'reminderEnabled': false,
          'reminderTime': 10,
        });
      }
    }
  }
}