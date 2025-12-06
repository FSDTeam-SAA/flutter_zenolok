class VerifyAccountRequestModel {
  final String email;
  final String otp;

  VerifyAccountRequestModel({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'otp': otp,
    };
  }
}
