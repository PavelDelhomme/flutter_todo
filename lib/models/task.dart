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

  Task({
    String? id,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    DateTime? createdAtDate,
    DateTime? createdAtTime,
    this.priorityLevel = 'Neutre',
    this.reminder,
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
  }) {
    return Task(
      title: title,
      subtitle: subtitle,
      createdAtDate: createdAtDate,
      createdAtTime: createdAtTime,
      priorityLevel: priorityLevel,
      reminder: reminder,
    );
  }

  void saveTask() {
    save();
  }

  void deleteTask() {
    delete();
  }
}
