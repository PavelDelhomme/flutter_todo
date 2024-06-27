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
  DateTime startDate;

  @HiveField(5)
  DateTime endDate;

  @HiveField(6)
  String priorityLevel;

  @HiveField(7)
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

  static Task create({
    required String title,
    required String subtitle,
    required DateTime startDate,
    required DateTime endDate,
    String priorityLevel = 'Neutre',
    required String userId,
  }) {
    return Task(
      title: title,
      subtitle: subtitle,
      startDate: startDate,
      endDate: endDate,
      priorityLevel: priorityLevel,
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
      'startDate': startDate,
      'endDate': endDate,
      'priorityLevel': priorityLevel,
      'userId': userId,
    };
  }

  static Task fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      isCompleted: map['isCompleted'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      priorityLevel: map['priorityLevel'],
      userId: map['userId'],
    );
  }
}
