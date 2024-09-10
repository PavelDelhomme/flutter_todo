import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
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
  String _userPassword = '';
  bool _isLoading = true; // Ajout d'un indicateur de chargement
  final _formKey = GlobalKey<FormState>();

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
        // Sauvegarde immédiate des paramètres de rappel
        await FirebaseFirestore.instance.collection('userSettings').doc(user.uid).set({
          'reminderEnabled': reminderEnabled,
          'reminderTime': reminderTime,
        }, SetOptions(merge: true));

        // Mise à jour des notifications après modification
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

  Future<void> _changeEmail() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_formKey.currentState!.validate() && user != null) {
      try {
        await user.verifyBeforeUpdateEmail(_userEmail);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email mis à jour avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour de l\'email : $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final user = FirebaseAuth.instance.currentUser;

    if (_formKey.currentState!.validate() && user != null) {
      try {
        await user.updatePassword(_userPassword);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mot de passe mis à jour avec succès'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la mise à jour du mot de passe : $e'),
            duration: const Duration(seconds: 2),
          ),
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
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: _userEmail,
                      decoration: const InputDecoration(labelText: "Email"),
                      validator: (value) => value!.isEmpty ? 'Ce champ ne peut être vide' : null,
                      onChanged: (value) => _userEmail = value,
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      obscureText: true,
                      decoration: const InputDecoration(labelText: "Nouveau mot de passe"),
                      validator: (value) => value!.isEmpty ? 'Ce champ ne peut être vide' : null,
                      onChanged: (value) => _userPassword = value,
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _changeEmail,
                      child: const Text('Changer l\'email'),
                    ),
                    ElevatedButton(
                      onPressed: _changePassword,
                      child: const Text('Changer le mot de passe'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}