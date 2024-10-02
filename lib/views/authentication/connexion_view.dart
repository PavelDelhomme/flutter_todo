import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../utils/authentication_provider.dart';
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
