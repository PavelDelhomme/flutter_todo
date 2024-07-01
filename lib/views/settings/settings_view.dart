import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:todo_firebase/services/task_service.dart';
import 'package:todo_firebase/models/category.dart';
import 'package:uuid/uuid.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late Box settingsBox;
  bool notificationsEnabled = false;
  bool darkModeEnabled = false;
  String reminderFrequency = 'Quotidien';
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadCategories();
  }

  Future<void> _loadSettings() async {
    settingsBox = await Hive.openBox('settings');
    setState(() {
      notificationsEnabled = settingsBox.get('notificationsEnabled', defaultValue: false);
      darkModeEnabled = settingsBox.get('darkModeEnabled', defaultValue: false);
      reminderFrequency = settingsBox.get('reminderFrequency', defaultValue: 'Quotidien');
    });
  }

  Future<void> _loadCategories() async {
    taskService.getCategories().listen((categoryList) {
      setState(() {
        categories = categoryList;
      });
    });
  }

  Future<void> _toggleNotifications(bool value) async {
    setState(() {
      notificationsEnabled = value;
    });
    await settingsBox.put('notificationsEnabled', value);
  }

  Future<void> _toggleDarkMode(bool value) async {
    setState(() {
      darkModeEnabled = value;
    });
    await settingsBox.put('darkModeEnabled', value);
  }

  Future<void> _setReminderFrequency(String? value) async {
    if (value != null) {
      setState(() {
        reminderFrequency = value;
      });
      await settingsBox.put('reminderFrequency', value);
    }
  }

  Future<void> _backupTasks() async {
    await taskService.backupTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sauvegarde réussie')),
    );
  }

  Future<void> _restoreTasks() async {
    await taskService.restoreTasks();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Restauration réussie')),
    );
  }

  Future<void> _addCategory(String categoryName) async {
    final category = Category(id: const Uuid().v4(), name: categoryName);
    await taskService.addCategory(category);
  }

  Future<void> _updateCategory(Category category, String newName) async {
    category.name = newName;
    await taskService.updateCategory(category);
  }

  Future<void> _deleteCategory(String categoryId) async {
    await taskService.deleteCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text('Activer les notifications'),
              value: notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            SwitchListTile(
              title: const Text('Mode sombre'),
              value: darkModeEnabled,
              onChanged: _toggleDarkMode,
            ),
            DropdownButton<String>(
              value: reminderFrequency,
              onChanged: _setReminderFrequency,
              items: <String>['Quotidien', 'Hebdomadaire', 'Mensuel']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              hint: const Text("Fréquence de rappel"),
            ),
            ElevatedButton(
              onPressed: _backupTasks,
              child: const Text('Sauvegarder les tâches'),
            ),
            ElevatedButton(
              onPressed: _restoreTasks,
              child: const Text('Restaurer les tâches'),
            ),
            const SizedBox(height: 20),
            const Text('Catégories', style: TextStyle(fontSize: 18)),
            Expanded(
              child: ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _deleteCategory(category.id),
                    ),
                    onTap: () async {
                      final newName = await _showEditCategoryDialog(context, category.name);
                      if (newName != null) {
                        _updateCategory(category, newName);
                      }
                    },
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newCategory = await _showAddCategoryDialog(context);
                if (newCategory != null) {
                  _addCategory(newCategory);
                }
              },
              child: const Text('Ajouter une catégorie'),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showAddCategoryDialog(BuildContext context) async {
    String? categoryName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une catégorie'),
          content: TextField(
            onChanged: (value) => categoryName = value,
            decoration: const InputDecoration(hintText: 'Nom de la catégorie'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(categoryName),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
    return categoryName;
  }

  Future<String?> _showEditCategoryDialog(BuildContext context, String currentName) async {
    TextEditingController _controller = TextEditingController(text: currentName);
    String? newName = currentName;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Modifier la catégorie'),
          content: TextField(
            controller: _controller,
            onChanged: (value) => newName = value,
            decoration: const InputDecoration(hintText: 'Nom de la catégorie'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(newName),
              child: const Text('Modifier'),
            ),
          ],
        );
      },
    );
    return newName;
  }
}
