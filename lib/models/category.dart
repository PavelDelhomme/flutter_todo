import 'package:hive/hive.dart';

part 'category.g.dart';
@HiveType(typeId: 1)
class Category extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  Category({required this.id, required this.name});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
    };
  }

  static Category fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'] ?? '',  // Ajoutez une valeur par défaut si id est null
      name: map['name'] ?? '',  // Ajoutez une valeur par défaut si name est null
    );
  }
}
