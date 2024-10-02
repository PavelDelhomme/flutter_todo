import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../utils/authentication_provider.dart';
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
  bool _isLoading = false;

  Future<void> _signIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<AuthenticationProvider>().signIn(
          email: _emailController.text,
          password: _passwordController.text,
        );
      } on FirebaseAuthException catch (e) {
        log("FirebaseAuthException: ${e.message}");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur: ${e.message}")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion')),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}


/*import 'dart:developer';

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
          _passwordController.text,
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
          _showErrorFlushbar("Identifiant ou mot de passe incorrect. Veuillez réessayez.");
        } else {
          // Gestion générique des erreurs
          _showErrorFlushbar("Erreur lors de la connexion");
        }
      } catch (e) {
        // Vérification si l'erreur est 'PigeonUserDetails et l'ignorer alors
        if (e.toString().contains('PigeonUserDetails')) {
          log("Erreur liée à PiegonUserDetails ignorée : $e");

          // Permettre la continuation de la connexion même avec l'erreur ignorée
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        } else {
          log("Erreur inattendue lors de la connexion : $e");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Echec de la connexion")),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _showErrorFlushbar(String message) {
    Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
    ).show(context);
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
}*/