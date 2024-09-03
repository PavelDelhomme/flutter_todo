import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

class Task {
  String id;
  String title;
  String subtitle;
  bool isCompleted;
  DateTime startDate;
  DateTime endDate;
  String priorityLevel;
  String userId;

  Task({
    String? id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    required this.startDate,
    required this.endDate,
    this.priorityLevel = 'Neutre',
    required this.userId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'priorityLevel': priorityLevel,
      'userId': userId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? const Uuid().v4(),
      title: map['title'] ?? '',  // Provide a default value to avoid null errors
      subtitle: map['subtitle'] ?? '',
      isCompleted: map['isCompleted'] ?? false,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(), // Use the current date if null
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now().add(Duration(hours: 1)),
      priorityLevel: map['priorityLevel'] ?? 'Neutre',
      userId: map['userId'] ?? FirebaseAuth.instance.currentUser!.uid,
    );
  }

}