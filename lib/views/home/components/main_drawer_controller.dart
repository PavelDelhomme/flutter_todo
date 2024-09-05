import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../settings/settings_view.dart';
import '../../tasks/widgets/list/tasks.dart';

class MainDrawerController extends StatefulWidget {
  const MainDrawerController({super.key});

  @override
  MainDrawerControllerState createState() => MainDrawerControllerState();
}

class MainDrawerControllerState extends State<MainDrawerController> {
  String _currentTitle = 'Tâches';
  Widget _currentScreen = const TasksList();

  void _selectScreen(String title, Widget screen) {
    setState(() {
      _currentTitle = title;
      _currentScreen = screen;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: Text(_currentTitle)),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(user?.displayName ?? 'Aucun nom'),
              accountEmail: Text(user?.email ?? "Aucun email"),
              currentAccountPicture: GestureDetector(
                onTap: () {
                  _selectScreen('Profil', const SettingsView());
                },
                child: CircleAvatar(
                  child: Text((user?.displayName?.isEmpty ?? true) ? '?' : user!.displayName!.substring(0, 1)),
                ),
              ),
              decoration: const BoxDecoration(color: Colors.blue),
            ),
            ListTile(
              leading: const Icon(Icons.list),
              title: const Text("Liste des tâches"),
              onTap: () => _selectScreen('Liste des tâches', const TasksList()),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => _selectScreen('Paramètres', const SettingsView()),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text("Déconnexion"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacementNamed('/login');
              },
            ),
          ],
        ),
      ),
      body: _currentScreen,
    );
  }
}