import 'category_model.dart';

class CreateCategoryResponse {
  final bool success;
  final String message;
  final CategoryModel data;

  CreateCategoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CreateCategoryResponse.fromJson(Map<String, dynamic> json) {
    return CreateCategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: CategoryModel.fromJson(json['data'] ?? {}),
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
