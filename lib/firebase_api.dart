// firebase_api.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseApi {
  static Future<FirebaseOptions> getFirebaseOptions() async {
    if (kIsWeb) {
      return const FirebaseOptions(
        apiKey: String.fromEnvironment('FIREBASE_API_KEY', defaultValue: "AIzaSyC9EN5HvjVK4CsgaHbaRu7fhog8GqT1WGU"),
        authDomain: String.fromEnvironment('FIREBASE_AUTH_DOMAIN', defaultValue: "oportal-fd9c0.firebaseapp.com"),
        projectId: String.fromEnvironment('FIREBASE_PROJECT_ID', defaultValue: "oportal-fd9c0"),
        storageBucket: String.fromEnvironment('FIREBASE_STORAGE_BUCKET', defaultValue: "oportal-fd9c0.appspot.com"),
        messagingSenderId: String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID', defaultValue: "856883764242"),
        appId: String.fromEnvironment('FIREBASE_APP_ID', defaultValue: "1:856883764242:web:095d302243f479bdbb8ccb"),
        measurementId: String.fromEnvironment('FIREBASE_MEASUREMENT_ID', defaultValue: "G-CSPFREW8HC"),
      );
    } else {
      await dotenv.load(fileName: ".env");
      return FirebaseOptions(
        apiKey: dotenv.env['FIREBASE_API_KEY']!,
        authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
        projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
        storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
        messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
        appId: dotenv.env['FIREBASE_APP_ID']!,
        measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
      );
    }
  }
}