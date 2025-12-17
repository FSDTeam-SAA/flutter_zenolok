import 'package:flutter/material.dart';

class CategoryDesign {
  final Color? color; // null => grey disabled
  final IconData icon; // UI icon
  final String iconKey; // backend icon key
  final String name;

  const CategoryDesign({
    required this.color,
    required this.icon,
    required this.iconKey,
    required this.name,
  });

  bool get isComplete => color != null;

  CategoryDesign copyWith({
    Color? color,
    IconData? icon,
    String? iconKey,
    String? name,
  }) {
    return CategoryDesign(
      color: color ?? this.color,
      icon: icon ?? this.icon,
      iconKey: iconKey ?? this.iconKey,
      name: name ?? this.name,
    );
  }
}
