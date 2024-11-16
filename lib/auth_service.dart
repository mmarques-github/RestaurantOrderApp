import 'package:crypto/crypto.dart';  // Ensure this import is correct
import 'dart:convert';  // Needed for utf8.encode
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hashing function
  String hashPassword(String password) {
    var bytes = utf8.encode(password); // Convert password to bytes
    var digest = sha256.convert(bytes); // Hash the bytes using SHA-256
    return digest.toString(); // Convert hash to string
  }

  // Sign up with custom username and hashed password
  Future<bool> signUp(String username, String password) async {
    try {
      final users = _firestore.collection('users');
      final existingUser = await users.doc(username).get();

      if (existingUser.exists) {
        print('Username already exists');
        return false;
      }

      String hashedPassword = hashPassword(password);

      await users.doc(username).set({
        'username': username,
        'password': hashedPassword,
        'createdAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      print('Error signing up: $e');
      return false;
    }
  }

  // Sign in with custom username and password
  Future<bool> signIn(String username, String password) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        if (userData != null && userData['password'] == password){ //hashPassword(password)) {
          print('Sign in successful');
          return true;
        } else {
          print('Incorrect password');
          return false;
        }
      } else {
        print('User does not exist');
        return false;
      }
    } catch (e) {
      print('Error signing in: $e');
      return false;
    }
  }

  // Get user info
  Future<Map<String, dynamic>?> getUserInfo(String username) async {
    try {
      final userDoc = await _firestore.collection('users').doc(username).get();
      if (userDoc.exists) {
        return userDoc.data();
      } else {
        print('User does not exist');
        return null;
      }
    } catch (e) {
      print('Error getting user info: $e');
      return null;
    }
  }
}
