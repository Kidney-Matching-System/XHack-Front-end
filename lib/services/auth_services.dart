import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/constants.dart';
import 'package:http/http.dart' as http;

class AuthService {
  /// Login
// AuthService.dart
static Future<http.Response> login(String email, String password) async {
  final response = await http.post(
    Uri.parse('${AppConstants.baseUrl}/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    final Map<String, dynamic> responseBody = jsonDecode(response.body);
    print(responseBody);
    final userId = responseBody['userId']; // adjust depending on your backend

    if (userId != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userId);
      print("✅ userId saved: $userId");
    } else {
      print("❌ userId not found in response");
    }
  } else {
    print("❌ Login failed: ${response.statusCode}");
  }

  return response; // 🔥 RETURN the response so caller can use it
}


  /// Forgot Password (Send OTP)
  static Future<http.Response> forgotPassword(String email) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );
    return response;
  }

  /// Verify OTP
  static Future<http.Response> verifyOtp(String otpCode) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/verify-otp'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'recoveryCode': otpCode}),
    );
    return response;
  }

  /// Reset Password
  static Future<http.Response> resetPassword(String newPassword, String resetToken) async {
    final response = await http.put(
      Uri.parse('${AppConstants.baseUrl}/reset-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'newPassword': newPassword,
        'resetToken': resetToken,
      }),
    );
    return response;
  }
}
