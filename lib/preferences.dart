import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static const String _keySelectedMenuType = 'selectedMenuType';
  static const String _keyUsername = 'username'; // Add this line

  static Future<void> setSelectedMenuType(String menuType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedMenuType, menuType);
  }

  static Future<String> getSelectedMenuType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedMenuType) ?? 'Daily';
  }

  // Add these methods for username
  static Future<void> setUsername(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUsername, username);
  }

  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUsername);
  }
}