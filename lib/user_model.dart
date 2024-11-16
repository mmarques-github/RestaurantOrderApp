import 'package:flutter/material.dart';

class UserModel with ChangeNotifier {
  String _userId = '';
  String _username = '';
  String _userType = '';

  String get userId => _userId;
  String get username => _username;
  String get userType => _userType;

  void setUser(String userId, String username, String userType) {
    _userId = userId;
    _username = username;
    _userType = userType;
    notifyListeners();
  }
}
