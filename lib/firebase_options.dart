// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC9EN5HvjVK4CsgaHbaRu7fhog8GqT1WGU',
    appId: '1:856883764242:web:0ae0e6a9fa586be4bb8ccb',
    messagingSenderId: '856883764242',
    projectId: 'oportal-fd9c0',
    authDomain: 'oportal-fd9c0.firebaseapp.com',
    storageBucket: 'oportal-fd9c0.appspot.com',
    measurementId: 'G-BZ3G9NMHZM',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAMgCV6e_odF9E3XvSPb4NRQ1H2xGtLPZs',
    appId: '1:856883764242:android:2978b0bb17f64861bb8ccb',
    messagingSenderId: '856883764242',
    projectId: 'oportal-fd9c0',
    storageBucket: 'oportal-fd9c0.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA7QDQ8IfbUYYn9ykRAsOUWcPumf3omB0I',
    appId: '1:856883764242:ios:6a2d5d26c923eb3dbb8ccb',
    messagingSenderId: '856883764242',
    projectId: 'oportal-fd9c0',
    storageBucket: 'oportal-fd9c0.appspot.com',
    iosBundleId: 'com.example.restaurantAppNew',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA7QDQ8IfbUYYn9ykRAsOUWcPumf3omB0I',
    appId: '1:856883764242:ios:6a2d5d26c923eb3dbb8ccb',
    messagingSenderId: '856883764242',
    projectId: 'oportal-fd9c0',
    storageBucket: 'oportal-fd9c0.appspot.com',
    iosBundleId: 'com.example.restaurantAppNew',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC9EN5HvjVK4CsgaHbaRu7fhog8GqT1WGU',
    appId: '1:856883764242:web:10ddf5baa3c8045fbb8ccb',
    messagingSenderId: '856883764242',
    projectId: 'oportal-fd9c0',
    authDomain: 'oportal-fd9c0.firebaseapp.com',
    storageBucket: 'oportal-fd9c0.appspot.com',
    measurementId: 'G-Z1N9T2VVWS',
  );

}