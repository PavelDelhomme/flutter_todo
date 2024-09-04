import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:todo_firebase/views/home/components/drawer_menu.dart';
import 'package:todo_firebase/views/tasks/widgets/form/edit_task.dart';
import 'package:todo_firebase/views/tasks/widgets/list/tasks.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String _currentTitle = 'Tâches';
  Widget _currentScreen = const TasksList();

  void _selectScreen(String title, Widget screen) {
    setState(() {
      _currentTitle = title;
      _currentScreen = screen;
    });
    Navigator.pop(context);
  }

  void _navigateToAddTask() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditTaskScreen(taskId: ''),
      ),
    ).then((_) {
      setState(() {
        _currentTitle = 'Tâches';
        _currentScreen = const TasksList();
      }); // Actualise l'interface après l'ajout de la tâche
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentTitle)),
      drawer: DrawerMenu(onSignOut: _selectScreen),
      body: _currentScreen,
      floatingActionButton: _currentTitle == 'Tâches' ? SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_task),
            label: 'Ajouter une tâche',
            onTap: _navigateToAddTask,
          ),
        ],
      ) : null,
    );
  }
}
