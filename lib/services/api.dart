import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:m_pro/models/register_request.dart';
import 'package:m_pro/services/shared_preferences/preferences_handler.dart';
import '../constant/endpoint.dart';
import '../models/login_model.dart';
import '../models/register_model.dart';

class AuthAPI {
  static Future<LoginModel> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return LoginModel.fromJson(json);
    } else {
      throw Exception(json["message"] ?? "Login failed");
    }
  }

  static Future<RegisterModel> registerUser(RegisterRequest request) async {
    final url = Uri.parse(Endpoint.register);

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(request.toJson()),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode == 200) {
      final registerModel = RegisterModel.fromJson(data);

      await PreferencesHandler.saveToken(registerModel.data?.token ?? "");

      return registerModel;
    }

    throw Exception(data["message"] ?? "Register failed");
  }

  static Future<void> requestOtp(String email) async {
    final url = Uri.parse(Endpoint.forgotPassword);

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Gagal mengirim OTP");
    }
  }

  static Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final url = Uri.parse(Endpoint.resetPassword);

    final res = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "otp": otp, "password": newPassword}),
    );

    final data = jsonDecode(res.body);

    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Reset password gagal");
    }
  }
}
