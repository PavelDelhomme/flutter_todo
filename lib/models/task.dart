import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

class Task {
  String id;
  String title;
  String subtitle;
  String notes;
  String priorityLevel;
  DateTime startDate;
  DateTime endDate;
  String userId;
  bool isCompleted;
  //todo définir l'état de la tâche pouvoir indiquer si elle est en cours, en retard, terminer, et que cela envoie donc différents notification toujours en fonction de l'état

  Task({
    String? id,
    required this.title,
    required this.subtitle,
    this.notes = '',
    this.priorityLevel = 'Neutre',
    required this.startDate,
    required this.endDate,
    required this.userId,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap({bool excludeId = false}) {
    final map = {
      'id': id, // OK Firebase
      'title': title, // OK Firebase
      'subtitle': subtitle, // OK Firebase
      'notes': notes, // Okay Firebase
      'priorityLevel': priorityLevel, // OK Firebase
      'startDate': Timestamp.fromDate(startDate), // OK Firebase
      'endDate': Timestamp.fromDate(endDate), // OK Firebase
      'userId': userId, // Ok Firebase
      'isCompleted': isCompleted, // Ok Firebase
    };

    if (!excludeId) {
      map['id'] = id;
    }

    return map;
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      notes: map['notes'] ?? '',
      priorityLevel: map['priorityLevel'] ?? 'Neutre',
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(const Duration(hours: 1)),
      userId: map['userId'], // Ne pas assigner l'utilisateur connecté ici, mais bien récupérer le `userId` du document Firestore
      isCompleted: map['isCompleted'] ?? false,
    );
  }

}