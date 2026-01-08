import 'scheduled_todo_item_model.dart';

class ScheduledTodosResponse {
  final bool success;
  final String message;
  final List<ScheduledTodoItem> data;

  ScheduledTodosResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ScheduledTodosResponse.fromJson(Map<String, dynamic> json) {
    return ScheduledTodosResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null
          ? List<ScheduledTodoItem>.from(
              (json['data'] as List).map(
                (item) => ScheduledTodoItem.fromJson(item as Map<String, dynamic>),
              ),
            )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}
