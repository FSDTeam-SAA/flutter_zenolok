class RegisterRequestModel {
  final String email;
  final String password;
  final String username;
  final bool termsAccepted;

  RegisterRequestModel({
    required this.email,
    required this.password,
    required this.username,
    required this.termsAccepted,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'username': username,
      'termsAccepted': termsAccepted,
    };
  }
}
