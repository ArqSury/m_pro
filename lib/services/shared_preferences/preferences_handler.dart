import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHandler {
  static const String isToken = 'isToken';

  static saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(isToken, value);
  }

  static getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(isToken);
  }

  static removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(isToken);
  }
}
