import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _isLoggedInKey = "IS_LOGGED_IN";
  static const String _userRoleKey = "USER_ROLE";

  static Future<void> saveLoginStatus(bool status, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, status);
    await prefs.setString(_userRoleKey, role);
  }

  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
