import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class EditTaskScreen extends StatefulWidget {
  final String taskId;

  const EditTaskScreen({Key? key, required this.taskId}) : super(key: key);

  @override
  _EditTaskScreenState createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  String title = '';
  String subtitle = '';
  String? notes = '';
  DateTime? startDate;
  DateTime? endDate;
  String priorityLevel = 'Neutre';
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
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection("tasks").doc(widget.taskId).get();
      var data = snapshot.data() as Map<String, dynamic>?;

      if (data != null) {
        setState(() {
          title = data['title'] ?? '';
          subtitle = data['subtitle'] ?? '';
          notes = data['notes'] ?? '';
          priorityLevel = data['priority'] ?? 'Neutre';
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

  Future<void> _saveOrUpdateTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final userId = FirebaseAuth.instance.currentUser!.uid;

    Map<String, dynamic> taskData = {
      'title': title,
      'subtitle': subtitle,
      'notes': notes,
      'priority': priorityLevel,
      'startDate': Timestamp.fromDate(startDate!),
      'endDate': Timestamp.fromDate(endDate!),
      'userId': userId,
      'isCompleted': false,
    };

    if (widget.taskId.isEmpty) {
      await FirebaseFirestore.instance.collection('tasks').add(taskData);
    } else {
      await FirebaseFirestore.instance.collection('tasks').doc(widget.taskId).update(taskData);
    }

    Navigator.pop(context);
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
              initialValue: title,
              decoration: const InputDecoration(labelText: "Titre de la tâche"),
              onSaved: (value) => title = value!,
              validator: (value) => value!.isEmpty ? 'Ce champ ne peut être vide' : null,
            ),
            TextFormField(
              initialValue: subtitle,
              decoration: const InputDecoration(labelText: "Sous-titre de la tâche"),
              onSaved: (value) => subtitle = value!,
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
              value: priorityLevel.isNotEmpty ? priorityLevel : null,
              items: ["Urgent", "Neutre", "Non urgent"].map((String priority) {
                return DropdownMenuItem<String>(
                  value: priority,
                  child: Text(priority),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Priorité'),
              onChanged: (value) => setState(() => priorityLevel = value ?? ''),
            ),
            TextFormField(
              initialValue: notes,
              decoration: const InputDecoration(labelText: 'Notes'),
              onSaved: (value) => notes = value!,
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
}
