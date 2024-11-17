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
    return prefs.getString(_keySelectedMenuType) ?? 'Daily'; // Default value
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

  static Future<void> setSelectedItemType(String itemType) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedItemType', itemType);
  }

  static Future<String> getSelectedItemType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('selectedItemType') ?? 'Menu'; // Default value
  }

  static Future<bool> getShowTableOrders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showTableOrders') ?? true;
  }

  static Future<void> setShowTableOrders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTableOrders', value);
  }

  static Future<bool> getShowTakeawayOrders() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('showTakeawayOrders') ?? true;
  }

  static Future<void> setShowTakeawayOrders(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTakeawayOrders', value);
  }

  static Future<bool> getGroupByItem() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('groupByItem') ?? false;
  }

  static Future<void> setGroupByItem(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('groupByItem', value);
  }
}