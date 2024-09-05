import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../authentication/connexion_view.dart';
import '../../settings/settings_view.dart';
import '../../tasks/widgets/list/tasks.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({super.key, required this.onSignOut});

  final Function(String, Widget) onSignOut;

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ConnexionView()),
        (Route<dynamic> route) => false,
    );
  }
  //final VoidCallback onSignOut;

  /*Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ConnexionView()),
          (Route<dynamic> route) => false,
    );
  }
  //final VoidCallback onSignOut;

  /*Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const ConnexionView()),
          (Route<dynamic> route) => false,
    );
    log("Déconnexion utilisateur");
  }*/*/

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user?.displayName ?? 'User'),
            accountEmail: Text(user?.email ?? 'No email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.list),
            title: const Text('Liste des tâches'),
            onTap: () => onSignOut('Tâches', const TasksList()),
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Paramètres'),
            onTap: () => onSignOut('Paramètres', const SettingsView()),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Déconnexion'),
            onTap: () => _signOut(context),
          ),
        ],
      ),
    );
  }
}