import 'package:flutter/material.dart';

class TaskFieldCategory extends StatelessWidget {
  final String selectedCategory;
  final List<String> categories;
  final Function(String?) onCategorySelected;

  const TaskFieldCategory({
    Key? key,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: 'Catégorie',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        value: selectedCategory,
        items: categories.map((category) {
          return DropdownMenuItem(
            value: category,
            child: Text(category),
          );
        }).toList(),
        onChanged: onCategorySelected,
        hint: const Text('Sélectionner une catégorie'),
      ),
    );
  }
}
