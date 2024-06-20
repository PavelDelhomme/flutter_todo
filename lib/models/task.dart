import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String subtitle;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  DateTime createdAtDate;

  @HiveField(5)
  DateTime createdAtTime;

  @HiveField(6)
  String priorityLevel;

  @HiveField(7)
  DateTime? reminder;

  @HiveField(8)
  String userId;

  Task({
    String? id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    DateTime? createdAtDate,
    DateTime? createdAtTime,
    this.priorityLevel = 'Neutre',
    this.reminder,
    required this.userId,
  })  : id = id ?? const Uuid().v4(),
        createdAtDate = createdAtDate ?? DateTime.now(),
        createdAtTime = createdAtTime ?? DateTime.now();

  static Task create({
    required String title,
    required String subtitle,
    DateTime? createdAtDate,
    DateTime? createdAtTime,
    String priorityLevel = 'Neutre',
    DateTime? reminder,
    required String userId,
  }) {
    return Task(
      title: title,
      subtitle: subtitle,
      createdAtDate: createdAtDate,
      createdAtTime: createdAtTime,
      priorityLevel: priorityLevel,
      reminder: reminder,
      userId: userId,
    );
  }

  void saveTask() {
    save();
  }

  void deleteTask() {
    delete();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'isCompleted': isCompleted,
      'createdAtDate': createdAtDate,
      'createdAtTime': createdAtTime,
      'priorityLevel': priorityLevel,
      'reminder': reminder,
      'userId': userId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      isCompleted: map['isCompleted'],
      createdAtDate: (map['createdAtDate'] as Timestamp).toDate(),
      createdAtTime: (map['createdAtTime'] as Timestamp).toDate(),
      priorityLevel: map['priorityLevel'],
      reminder: map['reminder'] != null ? (map['reminder'] as Timestamp).toDate() : null,
      userId: map['userId'],
    );
  }
}
