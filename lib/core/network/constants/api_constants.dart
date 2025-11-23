class ApiConstants {
  /// [Base Configuration]
  // static const String baseDomain = 'https://karlfive223-backend.onrender.com';
  static const String baseDomain = 'http://10.10.5.91:5001';
  static const String baseUrl = '$baseDomain/api/v1';

  /// [Headers]
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  static Map<String, String> authHeaders(String token) => {
    ...defaultHeaders,
    'Authorization': 'Bearer $token',
  };

  static Map<String, String> get multipartHeaders => {
    'Accept': 'application/json',
    // Content-Type will be set automatically for multipart
  };

  /// [Endpoint Groups]
  static AuthEndpoints get auth => AuthEndpoints();
  static UserEndpoints get user => UserEndpoints();
  static ContactEndpoints get contact => ContactEndpoints();
  static NotificationEndpoints get notification => NotificationEndpoints();
  static ReportEndpoints get report => ReportEndpoints();


  static get team => null;

  static get league => null;
}

/// [Authentication Endpoints]
class AuthEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/auth';

  final String login = '$_base/login';
  final String register = '$_base/register';
  final String resetPass = '$_base/send-reset-otp';
  final String refreshToken = '$_base/refresh-token';
  final String otpVerify = '$_base/verify-reset-otp';
  final String otpVerifyRegister = '$_base/verify-otp';
  final String setNewPass = '$_base/reset-password';
}

class UserEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/user';
  final String updateProfile = '$_base/update-profile';
  final String getUserProfile = '$_base/profile';

  // final String create = '$_base/create';
}

class NotificationEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/notification';

  final String getnotifications = '$_base/getnotifications';
}

class ContactEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/contact';
  final String createContact = '$_base/create';
}

class ReportEndpoints {
  static const String _base = '${ApiConstants.baseUrl}/report';

  /// Create a report (POST)
  final String createReport = '$_base/create';

  /// Optional — in case backend supports fetching user reports later
  final String getReports = '$_base/all';
}


