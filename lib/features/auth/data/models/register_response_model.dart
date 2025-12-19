class RegisterResponseModel {
  final String email;
  final String id;

  RegisterResponseModel({
    required this.email,
    required this.id,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      email: json['email'] ?? '',
      id: json['id'] ?? '',
    );
  }
}
