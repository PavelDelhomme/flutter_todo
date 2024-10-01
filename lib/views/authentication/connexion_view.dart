import 'dart:developer';

import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:todo_firebase/services/auth_service.dart';
import '../home/home_view.dart';
import 'inscription_view.dart';

class ConnexionView extends StatefulWidget {
  const ConnexionView({super.key});

  @override
  ConnexionViewState createState() => ConnexionViewState();
}


class ConnexionViewState extends State<ConnexionView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.signIn(
          _emailController.text,
          _emailController.text,
        );
        // Redirection vers HomeView après connexion réussie
        if (user != null && mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        }
      } on FirebaseAuthException catch (e) {
        log("FirebaseAuthException caught with code: ${e.code} and message: ${e.message}");

        if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
          Flushbar(
            message: "Identifiant ou mot de passe incorrect. Veuillez réessayer.",
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        } else {
          // Gestion générique des erreurs
          Flushbar(
            message: "Erreur lors de la connexion : ${e.message}",
            duration: const Duration(seconds: 3),
            flushbarPosition: FlushbarPosition.TOP,
          ).show(context);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Echec de la connexion"))
        );
        log("connexion_view : Erreur de la connexion $e");
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> _saveUserCredentials(User user) async {
    await const FlutterSecureStorage().write(key: 'userEmail', value: user.email);
    await const FlutterSecureStorage().write(key: 'userPassword', value: _passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connexion'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez indiquer votre email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez indiquer un mot de passe.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                onPressed: _signIn,
                child: const Text('Connexion'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const InscriptionView()),
                  );
                },
                child: const Text('Pas de compte ? Inscrivez-vous !'),
              )
            ],
          ),
        ),
      ),
    );
  }
}