# Todo Firebase Project 🚀

Bienvenue dans le projet Todo Firebase, une application de gestion de tâches développée avec Flutter et intégrée avec Firebase pour l'authentification et le stockage des données. Ce projet a été conçu pour démontrer les capacités de Flutter en tant que framework multiplateforme et l'intégration transparente avec Firebase.

## Fonctionnalités 🛠️

- **Authentification utilisateur** : Inscription et connexion via Firebase Authentication.
- **Gestion des tâches** : Ajout, mise à jour et suppression des tâches.
- **Notifications** : Notifications locales pour les rappels de tâches et les échéances.
- **Filtrage et tri** : Filtrer et trier les tâches par différents critères (fonctionnalité à venir).

## Prérequis 📋

- Flutter installé sur votre machine. [Guide d'installation](https://flutter.dev/docs/get-started/install)
- Compte Firebase avec un projet configuré. [Guide de configuration](https://firebase.google.com/docs/flutter/setup?platform=ios)

## Installation 🔧

1. Clonez le dépôt :
   sh
   git clone git@github.com:PavelDelhomme/todo_firebase.git
   cd todo_firebase

2. Installez les dépendances:
    flutter pub get

3. Configurer Firebase :
- Ajoutez le fichier **google-services.json** pour Android dans **android/app**

4. Démarrez l'application :
    flutter run


## Utilisation

1. Inscription/Connexion :
- L'écran d'accueil permet de s'inscrire ou de se connecter.
- Utilisez une adresse e-mail valide pour s'inscrire.

2. Gestion des tâches :
- Ajoutez une nouvelle tâche en cliquant sur le bouton flottant.
- Remplissez les détails de la tâche et enregistrez.

3. Notifications :
- Les notifications locales sont programmées afin de rappeler les tâche importantes et leurs échéances.
