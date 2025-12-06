class RegisterResponseModel {
  final String name;
  final String email;
  final String id;

  RegisterResponseModel({
    required this.name,
    required this.email,
    required this.id,
  });

  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      id: json['_id'] ?? '',
    );
  }
}
