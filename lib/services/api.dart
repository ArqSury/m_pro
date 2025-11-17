import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:m_pro/constant/endpoint.dart';
import 'package:m_pro/models/login_model.dart';
import 'package:m_pro/models/register_model.dart';

class AuthAPI {
  static Future<RegisterModel> registerUser({
    required String name,
    required String email,
    required String password,
    String? gender,
    int? batchId,
    int? trainingId,
    String? profilePhoto,
  }) async {
    final url = Uri.parse(Endpoint.register);

    final Map<String, dynamic> data = {
      "name": name,
      "email": email,
      "password": password,
      "gender": gender,
      "batch_id": batchId,
      "training_id": trainingId,
      if (profilePhoto != null) "profile_photo": profilePhoto,
    };

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    if (gender != "L" && gender != "P") {
      throw Exception(
        "Jenis kelamin must be either 'L' (Laki-laki) or 'P' (Perempuan).",
      );
    }

    log("REGISTER RESPONSE: ${response.body}");
    log("STATUS CODE: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return RegisterModel.fromJson(json.decode(response.body));
    } else {
      final error = json.decode(response.body);
      throw Exception(error["message"]);
    }
  }

  static Future<LoginModel> loginUser({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(Endpoint.login);

    final Map<String, dynamic> data = {"email": email, "password": password};

    final response = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode(data),
    );

    log("LOGIN RESPONSE: ${response.body}");
    log("STATUS CODE: ${response.statusCode}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginModel.fromJson(json.decode(response.body));
    }

    try {
      final error = json.decode(response.body);
      throw Exception(error["message"] ?? "Login failed");
    } catch (_) {
      throw Exception("Unexpected server response");
    }
  }
}
