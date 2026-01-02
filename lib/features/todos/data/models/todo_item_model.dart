import 'package:equatable/equatable.dart';

class TodoItem extends Equatable {
  final String id;
  final String categoryId;
  final String text;
  final bool isCompleted;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int version;

  const TodoItem({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.isCompleted,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    required this.version,
  });

  factory TodoItem.fromJson(Map<String, dynamic> json) {
    return TodoItem(
      id: json['_id'] ?? '',
      categoryId: json['categoryId'] ?? '',
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'categoryId': categoryId,
      'text': text,
      'isCompleted': isCompleted,
      'createdBy': createdBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': version,
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
      ];
}
