// lib/core/network/models/base_response.dart

import 'error_source.dart';

class BaseResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final List<ErrorSource>? errorSources;

  BaseResponse({
    required this.success,
    required this.message,
    this.data,
    this.errorSources,
  });

  factory BaseResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic) fromJsonT,
  ) {
    // Check if the response follows the standard structure
    if (json.containsKey('success') || json.containsKey('status')) {
      return BaseResponse<T>(
        success: json['success'] ?? json['status'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null ? fromJsonT(json['data']) : null,
        errorSources: json['errorSources'] != null
            ? (json['errorSources'] as List)
                .map((e) => ErrorSource.fromJson(e))
                .toList()
            : null,
      );
    } else {
      // Assume the response is the data itself (direct object)
      // This handles APIs that return the object directly without a wrapper
      try {
        return BaseResponse<T>(
          success: true,
          message: 'Success',
          data: fromJsonT(json),
        );
      } catch (e) {
        // If parsing fails, it might be an error response or unexpected format
        return BaseResponse<T>(
          success: false,
          message: 'Unexpected response format',
        );
      }
    }
  }

  String get combinedErrorMessage {
    if (errorSources == null || errorSources!.isEmpty) return message;
    return errorSources!.map((e) => e.message).join('\n');
  }
}