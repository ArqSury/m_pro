import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHandler {
  static const String isToken = 'isToken';
  static const String rememberMeKey = 'rememberMe';

  static saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isToken, value);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isToken);
  }

  static removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isToken);
  }

  static Future<void> saveRememberMe(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(rememberMeKey, value);
  }

  static Future<bool> getRememberMe() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(rememberMeKey) ?? false;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<void> saveDouble(String key, double value) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setDouble(key, value);
  }

  static Future<double?> getDouble(String key) async {
    final pref = await SharedPreferences.getInstance();
    return pref.getDouble(key);
  }

  static Future<void> remove(String key) async {
    final pref = await SharedPreferences.getInstance();
    await pref.remove(key);
  }
}
