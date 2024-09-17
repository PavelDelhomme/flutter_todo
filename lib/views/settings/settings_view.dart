import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/services/notification_service.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  SettingsViewState createState() => SettingsViewState();
}

class SettingsViewState extends State<SettingsView> {
  bool _reminderEnabled = false;
  int _reminderTime = 10; // Default reminder time in minutes
  String _userEmail = '';
  bool _isLoading = true; // Ajout d'un indicateur de chargement

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userEmail = user.email ?? '';
      final doc = await FirebaseFirestore.instance.collection('userSettings').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _reminderEnabled = doc['reminderEnabled'] ?? false;
          _reminderTime = doc['reminderTime'] ?? 10;
        });
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _updateReminderSettings(bool reminderEnabled, int reminderTime) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance.collection('userSettings').doc(user.uid).set({
          'reminderEnabled': reminderEnabled,
          'reminderTime': reminderTime,
        }, SetOptions(merge: true));

        await notificationService.updateNotificationsForUser(user.uid);
        log("Reminder settings updated : reminderEnabled : $reminderEnabled, reminderTime : $reminderTime");
      } catch (e) {
        log("Erreur lors de la mise à jour des paramètres de rappel : $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la mise à jour des paramètres : $e")),
        );
      }
    }
  }

  Future<void> _showChangeEmailDialog() async {
    final emailController = TextEditingController();
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Changer l'email"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: currentEmail,
                  decoration: const InputDecoration(labelText: 'Email actuel'),
                  enabled: false,
                ),
                TextFormField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Nouveau email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouvel email';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  await _changeEmail(emailController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showChangePasswordDialog() async {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Changer le mot de passe"),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: currentPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Mot de passe actuel'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer votre mot de passe actuel';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: newPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Nouveau mot de passe'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un nouveau mot de passe';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirmer le mot de passe'),
                  validator: (value) {
                    if (value == null || value != newPasswordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState?.validate() ?? false) {
                  await _changePassword(currentPasswordController.text, newPasswordController.text);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Confirmer'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _changeEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.updateEmail(newEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email mis à jour avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour de l\'email : $e')),
        );
      }
    }
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );

        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour avec succès')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour du mot de passe : $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Activer les rappels'),
              value: _reminderEnabled,
              onChanged: (value) {
                setState(() {
                  _reminderEnabled = value;
                });
                _updateReminderSettings(value, _reminderTime);
              },
            ),
            if (_reminderEnabled)
              ListTile(
                title: const Text('Rappel avant la tâche (minutes)'),
                trailing: DropdownButton<int>(
                  value: _reminderTime,
                  items: [5, 10, 15, 20, 30, 40, 45, 50, 55, 60]
                      .map((int value) => DropdownMenuItem<int>(
                    value: value,
                    child: Text(value.toString()),
                  ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _reminderTime = value;
                      });
                      _updateReminderSettings(_reminderEnabled, value);
                    }
                  },
                ),
              ),
            const Divider(
              height: 40,
              thickness: 2.5,
              indent: 20,
              endIndent: 20,
              color: Colors.deepPurple,
            ),
            const Text(
              "Paramètres utilisateur",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showChangeEmailDialog,
              child: const Text('Changer l\'email'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _showChangePasswordDialog,
              child: const Text('Changer le mot de passe'),
            ),
          ],
        ),
      ),
    );
  }
}
