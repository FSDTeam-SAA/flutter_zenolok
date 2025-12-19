import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_zenolok/features/auth/data/models/register_request_model.dart';
import 'package:flutter_zenolok/features/auth/data/models/register_response_model.dart';

void main() {
  group('Register Models Tests', () {
    test('RegisterRequestModel should match your API structure', () {
      final request = RegisterRequestModel(
        email: "abuzafor.dev@gmail.com",
        password: "Secret123!",
        username: "zafor",
        termsAccepted: true,
      );

      final json = request.toJson();

      expect(json, equals({
        "email": "abuzafor.dev@gmail.com",
        "password": "Secret123!",
        "username": "zafor",
        "termsAccepted": true,
      }));

      print("✅ RegisterRequestModel correctly matches your API request structure");
    });

    test('RegisterResponseModel should parse your API response correctly', () {
      const String jsonResponse = '''
      {
        "email": "abuzafor.dev@gmail.com",
        "id": "6944bdf8f2d527cd905209e5"
      }
      ''';

      final jsonMap = json.decode(jsonResponse) as Map<String, dynamic>;
      final response = RegisterResponseModel.fromJson(jsonMap);

      expect(response.email, equals("abuzafor.dev@gmail.com"));
      expect(response.id, equals("6944bdf8f2d527cd905209e5"));

      print("✅ RegisterResponseModel correctly parses your API response structure");
    });
  });
}