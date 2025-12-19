import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zenolok/features/auth/data/models/verify_account_request_model.dart';

void main() {
  group('Email Verification Tests', () {
    test('VerifyAccountRequestModel should match API structure', () {
      final request = VerifyAccountRequestModel(
        email: "abuzafor.dev@gmail.com",
        otp: "678855",
      );

      final json = request.toJson();

      expect(json, equals({
        "email": "abuzafor.dev@gmail.com",
        "otp": "678855",
      }));

      print("✅ VerifyAccountRequestModel correctly matches API request structure");
    });

    test('should handle different OTP formats', () {
      final request1 = VerifyAccountRequestModel(
        email: "test@example.com",
        otp: "123456",
      );

      final request2 = VerifyAccountRequestModel(
        email: "test@example.com", 
        otp: "000000",
      );

      expect(request1.toJson()['otp'], equals("123456"));
      expect(request2.toJson()['otp'], equals("000000"));

      print("✅ Handles different OTP formats correctly");
    });
  });
}