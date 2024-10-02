import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:todo_firebase/services/notification_service.dart';

import '../../../../models/task.dart';
import '../../../../services/task_service.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({super.key, required this.taskId});

  @override
  EditTaskScreenState createState() => EditTaskScreenState();
}

class EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String titleField = '';
  String subtitleField = '';
  String? notesField = '';
  DateTime? startDate;
  DateTime? endDate;
  String priorityLevelField = 'Neutre';
  bool _isLoading = true;

  late TextEditingController _startDateController;
  late TextEditingController _endDateController;

  @override
  void initState() {
    super.initState();
    log("initState called");
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    if (widget.taskId.isNotEmpty) {
      log("Task ID is not empty, loading initial data");
      loadInitialData();
    } else {
      log("Creating a new task, setting default start and end dates");
      startDate = DateTime.now();
      endDate = startDate!.add(const Duration(hours: 1));
      _startDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(startDate!);
      _endDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(endDate!);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> loadInitialData() async {
    log("Loading initial data for task: ${widget.taskId}");
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("tasks").doc(widget.taskId).get();
      log("Snapshot retrieved for task: ${widget.taskId}");
      var data = snapshot.data() as Map<String, dynamic>?;
      log("Data from snapshot: $data");

      if (data != null) {
        log("Populating fields with existing task data");
        setState(() {
          titleField = data['title'] ?? '';
          subtitleField = data['subtitle'] ?? '';
          notesField = data['notes'] ?? '';
          priorityLevelField = data['priority'] ?? 'Neutre';
          startDate = (data['startDate'] as Timestamp).toDate();
          endDate = (data['endDate'] as Timestamp).toDate();
          _startDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(startDate!);
          _endDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(endDate!);
          _isLoading = false;
        });
      } else {
        log("No data found for task: ${widget.taskId}");
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      log("Error loading initial data: $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des données : $e")),
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    log("Selecting start date");
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      log("Start date selected: $pickedDate");
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(startDate ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          startDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _startDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(startDate!);
          log("Start date and time set to: $startDate");

          // Automatically update end date
          endDate = startDate!.add(const Duration(hours: 1));
          _endDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(endDate!);
          log("End date and time automatically set to: $endDate");
        });
      }
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    log("Selecting end date");
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      log("End date selected: $pickedDate");
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(endDate ?? DateTime.now().add(const Duration(hours: 1))),
      );

      if (pickedTime != null) {
        setState(() {
          endDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
          _endDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(endDate!);
          log("End date and time set to: $endDate");
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    log("Building widget tree");
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.taskId.isEmpty ? "Créer une tâche" : "Modifier une tâche"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            TextFormField(
              initialValue: titleField,
              decoration: const InputDecoration(labelText: "Titre de la tâche"),
              onSaved: (value) {
                log("Title field saved with value: $value");
                titleField = value!;
              },
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Ce champ ne peut être vide';
                }
                return null;
              },
            ),
            TextFormField(
              initialValue: subtitleField,
              decoration: const InputDecoration(labelText: "Sous-titre de la tâche"),
              onSaved: (value) {
                log("Subtitle field saved with value: $value");
                subtitleField = value!;
              },
            ),
            TextFormField(
              controller: _startDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date et heure de début',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () => _selectStartDate(context),
                ),
              ),
            ),
            TextFormField(
              controller: _endDateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Date et heure de fin',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.edit_calendar_sharp),
                  onPressed: () => _selectEndDate(context),
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              value: priorityLevelField.isNotEmpty ? priorityLevelField : null,
              items: ["Urgent", "Neutre", "Non urgent"].map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Priorité'),
              onChanged: (value) {
                log("Priority level changed to: $value");
                setState(() => priorityLevelField = value ?? '');
              },
            ),
            TextFormField(
              initialValue: notesField,
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) {
                log("Notes field saved with value: $value");
                notesField = value!;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveOrUpdateTask,
              child: Text(widget.taskId.isEmpty ? "Créer la tâche" : "Mettre à jour la tâche"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveOrUpdateTask() async {
    log("Save or update task triggered");
    if (!_formKey.currentState!.validate()) {
      log("Form validation failed");
      return;
    }

    _formKey.currentState!.save();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      log("User is not authenticated");
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur : l'utilisateur n'est pas authentifié."))
      );
      return;
    }

    log("User authenticated with UID: $userId");

    final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
    String taskId = widget.taskId.isEmpty ? taskCollection.doc().id : widget.taskId;
    log("Task ID is: $taskId");
    log("userId : $userId");

    Map<String, dynamic> taskData = {
      'id': taskId,
      'title': titleField.isNotEmpty ? titleField : 'Tâche sans titre',
      'subtitle': subtitleField,
      'notes': notesField ?? '',
      'priorityLevel': priorityLevelField.isNotEmpty ? priorityLevelField : 'Neutre',
      'startDate': Timestamp.fromDate(startDate ?? DateTime.now()),
      'endDate': Timestamp.fromDate(endDate ?? DateTime.now().add(const Duration(hours: 1))),
      'userId': userId,
      'isCompleted': false,
    };

    try {
      final task = Task.fromMap(taskData);
      log("Task object created from data: $taskData");

      if (widget.taskId.isEmpty) {
        log("Creating new task");
        await taskService.addTask(task);
        log("Task created successfully");
      } else {
        log("Updating existing task with ID: $taskId");
        await taskService.updateTask(task);
        log("Task updated successfully");
      }

      DocumentSnapshot userSettingsDoc = await FirebaseFirestore.instance.collection('userSettings').doc(userId).get();
      Map<String, dynamic> userSettings = userSettingsDoc.data() as Map<String, dynamic>;
      log("User settings retrieved: $userSettings");

      await notificationService.updateNotifications(userSettings);
      log("Notifications updated based on user settings");

      Navigator.pop(context, task);
    } catch (e) {
      log("Error during task save/update: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de l'enregistrement de la tâche $e")),
      );
    }
  }
}