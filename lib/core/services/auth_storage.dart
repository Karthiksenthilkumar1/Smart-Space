import 'package:shared_preferences/shared_preferences.dart';

class AuthStorage {
  static const String tokenKey = "auth_token";
  static const String roleKey = "user_role";

  static Future<void> saveAuthData({
    required String token,
    required String role,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(tokenKey, token);
    await prefs.setString(roleKey, role);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(roleKey);
  }

  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(tokenKey);
    await prefs.remove(roleKey);
  }
}