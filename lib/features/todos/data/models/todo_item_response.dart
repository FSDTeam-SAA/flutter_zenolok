import 'todo_item_model.dart';

class TodoItemResponse {
  final bool success;
  final String message;
  final TodoItem data;

  TodoItemResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory TodoItemResponse.fromJson(Map<String, dynamic> json) {
    return TodoItemResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TodoItem.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}
