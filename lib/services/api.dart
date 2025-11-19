import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:m_pro/models/history_absen.dart';
import 'package:m_pro/models/register_request.dart';
import 'package:m_pro/models/user_model.dart';
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

  static Future<UserModel> getProfile() async {
    final token = await PreferencesHandler.getToken();
    final res = await http.get(
      Uri.parse(Endpoint.profile),
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("PROFILE RESPONSE: ${res.statusCode} - ${res.body}");

    try {
      final data = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return UserModel.fromJson(data);
      } else {
        throw Exception(data["message"] ?? "Gagal memuat profil");
      }
    } on FormatException {
      throw Exception("Response profil bukan JSON: ${res.body}");
    }
  }

  static Future<Map<String, dynamic>?> getAbsenToday() async {
    final token = await PreferencesHandler.getToken();
    final today = DateFormat("yyyy-MM-dd").format(DateTime.now());

    final uri = Uri.parse(
      Endpoint.absenToday,
    ).replace(queryParameters: {"attendance_date": today});

    final res = await http.get(
      uri,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("ABSEN TODAY RESPONSE: ${res.statusCode} - ${res.body}");

    if (res.statusCode == 404) {
      return null;
    }

    try {
      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return decoded["data"];
      } else {
        throw Exception(decoded["message"] ?? "Gagal ambil absen hari ini");
      }
    } on FormatException {
      throw Exception("Response absenToday bukan JSON: ${res.body}");
    }
  }

  static Future<Map<String, dynamic>?> getAbsenStats() async {
    final token = await PreferencesHandler.getToken();
    final now = DateTime.now();
    final start = DateFormat("yyyy-MM-01").format(now);
    final end = DateFormat("yyyy-MM-dd").format(now);

    final uri = Uri.parse(
      Endpoint.absenStats,
    ).replace(queryParameters: {"start": start, "end": end});

    final res = await http.get(
      uri,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    print("ABSEN STATS RESPONSE: ${res.statusCode} - ${res.body}");

    try {
      final decoded = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return decoded["data"];
      } else {
        throw Exception(decoded["message"] ?? "Gagal ambil statistik absen");
      }
    } on FormatException {
      throw Exception("Response absenStats bukan JSON: ${res.body}");
    }
  }

  static Future<void> absenCheckIn({
    required double latitude,
    required double longitude,
  }) async {
    final token = await PreferencesHandler.getToken();
    final url = Uri.parse("${Endpoint.baseUrl}/absen/check-in");

    final now = DateTime.now();
    final body = {
      "attendance_date": DateFormat("yyyy-MM-dd").format(now),
      "check_in": DateFormat("HH:mm").format(now),
      "check_in_lat": latitude,
      "check_in_lng": longitude,
      "check_in_address": "Lokasi otomatis",
      "status": "masuk",
    };

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("CHECK-IN RAW: ${res.body}");

    try {
      final json = jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw Exception(json["message"]);
      }
    } catch (e) {
      throw Exception("Invalid JSON: ${res.body}");
    }
  }

  static Future<void> absenCheckOut({
    required double latitude,
    required double longitude,
  }) async {
    final token = await PreferencesHandler.getToken();
    final url = Uri.parse(Endpoint.checkout);

    final now = DateTime.now();
    final body = {
      "attendance_date": DateFormat("yyyy-MM-dd").format(now),
      "check_out": DateFormat("HH:mm").format(now),
      "check_out_lat": latitude,
      "check_out_lng": longitude,
      "check_out_location": "$latitude,$longitude",
      "check_out_address": "Lokasi otomatis",
    };

    final res = await http.post(
      url,
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(body),
    );

    print("CHECK-OUT RAW: ${res.statusCode} - ${res.body}");

    try {
      final json = jsonDecode(res.body);
      if (res.statusCode != 200) {
        throw Exception(json["message"] ?? "Gagal absen pulang");
      }
    } catch (_) {
      throw Exception("Invalid JSON: ${res.body}");
    }
  }

  static Future<void> submitIzin({
    required String date,
    required String alasan,
  }) async {
    final url = Uri.parse("${Endpoint.baseUrl}/absen/izin");
    final token = await PreferencesHandler.getToken();

    final res = await http.post(
      url,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
      body: {"date": date, "alasan_izin": alasan},
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data["message"] ?? "Gagal mengirim izin");
    }
  }

  static Future<List<HistoryAbsen>> getAbsenHistory() async {
    final token = await PreferencesHandler.getToken();

    final res = await http.get(
      Uri.parse("${Endpoint.baseUrl}/absen/history"),
      headers: {"Authorization": "Bearer $token"},
    );

    print("HISTORY RESPONSE: ${res.statusCode} - ${res.body}");

    if (res.statusCode != 200) {
      throw Exception("Gagal mengambil riwayat");
    }

    final json = jsonDecode(res.body);

    if (json["data"] == null) return [];

    List list = json["data"];

    return list.map((e) => HistoryAbsen.fromJson(e)).toList();
  }

  static Future<List<dynamic>> getHistory({String? start, String? end}) async {
    final token = await PreferencesHandler.getToken();

    final params = {
      if (start != null) "start": start,
      if (end != null) "end": end,
    };

    final uri = Uri.parse(
      "${Endpoint.baseUrl}/absen/history",
    ).replace(queryParameters: params);

    final res = await http.get(
      uri,
      headers: {"Accept": "application/json", "Authorization": "Bearer $token"},
    );

    final body = jsonDecode(res.body);

    if (res.statusCode != 200) {
      return [];
    }

    return body["data"] ?? [];
  }
}
