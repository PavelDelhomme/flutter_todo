import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import '../../../../utils/custom_str.dart';
import '../details/details_task.dart';
import '../form/edit_task.dart';

class TasksList extends StatelessWidget {
  const TasksList({Key? key}) : super(key: key);

  String formatDateTime(DateTime? dateTime) {
    return dateTime != null ? DateFormat('EEE d MMM yyyy à HH:mm').format(dateTime) : CustomStr.noReminder;
  }

  Color _getTaskColor(DateTime startDate, DateTime endDate, bool isCompleted) {
    if (isCompleted) {
      return Colors.green.withOpacity(0.6); // Green for completed tasks
    } else if (endDate.isBefore(DateTime.now())) {
      return Colors.red.withOpacity(0.6); // Red for overdue tasks
    } else if (startDate.isBefore(DateTime.now()) && endDate.isAfter(DateTime.now())) {
      return Colors.orangeAccent.withOpacity(0.6); // Yellow-orange for tasks due today
    } else {
      return Colors.white; // White for tasks due later
    }
  }

  void _deleteTask(String id) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
  }

  @override
  Widget build(BuildContext context) {
    /*
    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .orderBy('startDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text(CustomStr.errorLoadingDatas));
          }

          var docs = snapshot.data!.docs;
          if (docs.isEmpty) {
            return const Center(child: Text(CustomStr.noTaskYet));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              var task = docs[index].data() as Map<String, dynamic>;

              DateTime startDate = (task['startDate'] as Timestamp).toDate();
              DateTime endDate = (task['endDate'] as Timestamp).toDate();
              bool isCompleted = task['isCompleted'] ?? false;

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TaskDetailsScreen(taskId: docs[index].id),
                    ),
                  );
                },
                child: Dismissible(
                  key: Key(docs[index].id),
                  background: Container(color: Colors.red),

                  direction: DismissDirection.horizontal,
                  confirmDismiss: (direction) async {
                    if (direction == DismissDirection.startToEnd) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditTaskScreen(taskId: docs[index].id),
                        ),
                      );
                      return false;
                    }
                    else if (direction == DismissDirection.endToStart) {
                      return await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text(CustomStr.confirm),
                            content: const Text(CustomStr.wantToDeleteTask),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(false),
                                child: const Text(CustomStr.abord),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(true),
                                child: const Text(CustomStr.delete),
                              ),
                            ],
                          );
                        },
                      );
                    }
                    return false;
                  },
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      _deleteTask(docs[index].id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text(CustomStr.deletedTask)),
                      );
                    }
                    else if (direction == DismissDirection.startToEnd) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => EditTaskScreen(taskId: docs[index].id),
                        ),
                      );
                    }
                  },
                  background: Container(
                    color: Colors.green,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.edit, color: Colors.white),
                  ),
                  secondaryBackground: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: Card(
                    color: _getTaskColor(startDate, endDate, isCompleted),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Checkbox(
                        value: isCompleted,
                        onChanged: (bool? value) {
                          FirebaseFirestore.instance.collection('tasks').doc(docs[index].id).update({'isCompleted': value});
                        },
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          color: isCompleted ? Colors.white : Colors.black,
                          decoration: isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            task['subtitle'] ?? '',
                            style: TextStyle(
                              color: isCompleted ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            'Début : ${formatDateTime(startDate)}',
                            style: TextStyle(
                              color: isCompleted ? Colors.white70 : Colors.black54,
                            ),
                          ),
                          Text(
                            'Fin : ${formatDateTime(endDate)}',
                            style: TextStyle(
                              color: isCompleted ? Colors.white70 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        spaceBetweenChildren: 4,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add_task),
            label: CustomStr.addNewTask,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditTaskScreen(taskId: ''),
              ),
            ),
          ),
        ],
      ),
    );*/
  }
}