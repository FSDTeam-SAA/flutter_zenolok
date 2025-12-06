import 'user_model.dart';

class AuthResponseData {
  final String accessToken;
  final String refreshToken;
  final String role;
  final String id;
  final UserModel user;

  AuthResponseData({
    required this.accessToken,
    required this.refreshToken,
    required this.role,
    required this.id,
    required this.user,
  });

  factory AuthResponseData.fromJson(Map<String, dynamic> json) {
    return AuthResponseData(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      role: json['role'] as String,
      id: json['_id'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'role': role,
      '_id': id,
      'user': user.toJson(),
    };
  }
}