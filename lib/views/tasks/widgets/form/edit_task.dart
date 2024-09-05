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
    _startDateController = TextEditingController();
    _endDateController = TextEditingController();
    if (widget.taskId.isNotEmpty) {
      loadInitialData();
    } else {
      startDate = DateTime.now();
      endDate = startDate!.add(const Duration(hours: 1));
      _startDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(startDate!);
      _endDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(endDate!);
      _isLoading = false;
    }
  }

  Future<void> loadInitialData() async {
    log("edit_task : loadInitialData : taskId received in widget : ${widget.taskId}");
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("tasks").doc(widget.taskId).get();
      log("edit_task : loadInitialData : snapshot correctly retrieved");
      var data = snapshot.data() as Map<String, dynamic>?;
      log("edit_task : loadInitialData : data from snapshot : $data");

      if (data != null) {
        log("edit_task : loadInitialdata : data not null retrieve older data known");
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
      }
    } catch (e) {
      log("Erreur lors du chargement des données : $e");
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors du chargement des données : $e")),
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: startDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
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

          // Mettre à jour automatiquement la date de fin
          endDate = startDate!.add(const Duration(hours: 1));
          _endDateController.text = DateFormat('yyyy-MM-dd HH:mm').format(endDate!);
        });
      }
    }
  }
  Future<void> _selectEndDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: endDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
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
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              onSaved: (value) => titleField = value!,
              validator: (value) => value!.isEmpty ? 'Ce champ ne peut être vide' : null,
            ),
            TextFormField(
              initialValue: subtitleField,
              decoration: const InputDecoration(labelText: "Sous-titre de la tâche"),
              onSaved: (value) => subtitleField = value!,
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
              onChanged: (value) => setState(() => priorityLevelField = value ?? ''),
            ),
            TextFormField(
              initialValue: notesField,
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) => notesField = value!,
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
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    final CollectionReference taskCollection = FirebaseFirestore.instance.collection('tasks');
    String taskId = widget.taskId.isEmpty ? taskCollection.doc().id : widget.taskId; // Création d'un nouvel id si la tâche n'existe pas et n'est pas trouvé dans la collection

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

      if (widget.taskId.isEmpty) {
        // Create task
        await taskService.addTask(task);
      } else {
        // Update task
        await taskService.updateTask(task);
      }

      // Notif démarrage
      await notificationService.scheduleNotification(
        id: task.id.hashCode,
        title: "Démarrage de la tâche ${task.title}",
        body: "${task.title} commence maintenant",
        taskDate: task.startDate,
        typeNotification: "start",
      );
      // Notif de rappel
      await notificationService.scheduleNotification(
        id: task.id.hashCode+1,
        title: "Rappel de la tâche ${task.title}",
        body: "${task.title} commence bientôt",
        taskDate: task.startDate,
        typeNotification: "reminder",
      );

      Navigator.pop(context);
    } catch (e) {
      log("Erreur lors de l'ajout ou de la mise à jour de la tâche : $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text("Erreur lors de l'enregistrement de la tâche $e")),
      );
    }
  }
}