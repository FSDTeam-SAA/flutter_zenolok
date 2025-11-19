class UserModel {
  final String? otp;
  final String? otpExpiry;
  final String id;
  final String name;
  final String email;
  final String password;
  final String? profileImage;
  final String role;
  final String phoneNumber;
  final bool isVerified;
  final String? resetOtp;
  final String? resetOtpExpiry;
  final String refreshToken;
  final String createdAt;
  final String updatedAt;
  final int v;

  UserModel({
    this.otp,
    this.otpExpiry,
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    this.profileImage,
    required this.role,
    required this.phoneNumber,
    required this.isVerified,
    this.resetOtp,
    this.resetOtpExpiry,
    required this.refreshToken,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      otp: json['otp'],
      otpExpiry: json['otpExpiry'],
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      profileImage: json['profileImage'],
      role: json['role'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      isVerified: json['isVerified'] ?? false,
      resetOtp: json['reset_otp'],
      resetOtpExpiry: json['reset_otpExpiry'],
      refreshToken: json['refreshToken'] ?? '',
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'otpExpiry': otpExpiry,
      '_id': id,
      'name': name,
      'email': email,
      'password': password,
      'profileImage': profileImage,
      'role': role,
      'phoneNumber': phoneNumber,
      'isVerified': isVerified,
      'reset_otp': resetOtp,
      'reset_otpExpiry': resetOtpExpiry,
      'refreshToken': refreshToken,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      '__v': v,
    };
  }
}