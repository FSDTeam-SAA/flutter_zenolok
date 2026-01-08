import 'package:equatable/equatable.dart';

class ScheduledTodoItem extends Equatable {
  final String id;
  final CategoryData? categoryId;
  final String text;
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;
  final String sectionLabel;

  const ScheduledTodoItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.isCompleted,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
    required this.sectionLabel,
  });

  factory ScheduledTodoItem.fromJson(Map<String, dynamic> json) {
    return ScheduledTodoItem(
      id: json['_id'] ?? '',
      categoryId: json['categoryId'] != null && json['categoryId'] is Map
          ? CategoryData.fromJson(json['categoryId'] as Map<String, dynamic>)
          : null,
      text: json['text'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      createdBy: json['createdBy'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      version: json['__v'] ?? 0,
      sectionLabel: json['sectionLabel'] ?? 'No Date',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryId': categoryId?.toJson(),
      'text': text,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
      'sectionLabel': sectionLabel,
    };
  }

  @override
  List<Object?> get props => [
        id,
        categoryId,
        text,
        isCompleted,
        createdBy,
        createdAt,
        updatedAt,
        version,
        sectionLabel,
      ];
}

class CategoryData extends Equatable {
  final String id;
  final String name;
  final String color;

  const CategoryData({
    required this.id,
    required this.name,
    required this.color,
  });

  factory CategoryData.fromJson(Map<String, dynamic> json) {
    return CategoryData(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      color: json['color'] ?? '#000000',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'color': color,
    };
  }

  @override
  List<Object?> get props => [id, name, color];
}
