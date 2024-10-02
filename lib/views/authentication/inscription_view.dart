import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../utils/authentication_provider.dart';
import '../home/home_view.dart';

class InscriptionView extends StatefulWidget {
  const InscriptionView({super.key});

  @override
  InscriptionViewState createState() => InscriptionViewState();
}

class InscriptionViewState extends State<InscriptionView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        await context.read<AuthenticationProvider>().signUp(
          email: _emailController.text,
          password: _passwordController.text,
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeView()),
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
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez indiquer votre email.';
                  }
                  return null;
                },
              ),
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
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signUp,
                child: const Text('Inscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_firebase/services/auth_service.dart';
import '../home/home_view.dart';

class InscriptionView extends StatefulWidget {
  const InscriptionView({super.key});

  @override
  InscriptionViewState createState() => InscriptionViewState();
}

class InscriptionViewState extends State<InscriptionView> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final AuthService _authService = AuthService();

  Future<void> _signUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        User? user = await _authService.signUp(
            _emailController.text,
            _passwordController.text,
        );
        
        if (user != null && mounted) {
          // Attendre la création des documents utilisateur avant de passer à l'écran suivant
          await Future.delayed(const Duration(seconds: 2)); // Délai pour garantir la création des documents

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const HomeView()),
          );
        } else {
          log("Erreur : utilisateur non créé correctement.");
          _showErrorSnackbar("Erreur lors de la création du compte. Veuillez réessayer.");
        }

      /*} on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Cette adresse email est déjà utilisée.';
          log("Erreur de l'inscription : $errorMessage");
        } else {
          errorMessage = 'Échec de l\'inscription : ${e.message}';
          log("Erreur de l'inscription : $errorMessage");
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );*/
      } catch (e) {
        log("Erreur lors de l'inscription : $e");
        _showErrorSnackbar("Erreur lors de l'inscription : $e");

        // Ignorer l'erreur quand même
        log("Erreur ignorée lors de l'inscription : $e");
        // Redirection malgré l'erreur
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeView()),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez indiquer votre email.';
                  }
                  return null;
                },
              ),
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
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _signUp,
                child: const Text('Inscription'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/