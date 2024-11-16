import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Keep this for mobile platforms
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'signin_screen.dart';
import 'user_model.dart';
import 'kitchen_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseOptions firebaseOptions;

  if (kIsWeb) {
    // Provide the Firebase options directly for web
    firebaseOptions = FirebaseOptions(
      apiKey: "AIzaSyC9EN5HvjVK4CsgaHbaRu7fhog8GqT1WGU", // #FILTER: sensitive
      authDomain: "oportal-fd9c0.firebaseapp.com", // #FILTER: sensitive
      projectId: "oportal-fd9c0", // #FILTER: sensitive
      storageBucket: "oportal-fd9c0.appspot.com", // #FILTER: sensitive
      messagingSenderId: "856883764242", // #FILTER: sensitive
      appId: "1:856883764242:web:095d302243f479bdbb8ccb", // #FILTER: sensitive
      measurementId: "G-CSPFREW8HC", // #FILTER: sensitive
    );
  } else {
    // Use dotenv for mobile platforms
    await dotenv.load(fileName: ".env");

    firebaseOptions = FirebaseOptions(
      apiKey: dotenv.env['FIREBASE_API_KEY']!,
      authDomain: dotenv.env['FIREBASE_AUTH_DOMAIN']!,
      projectId: dotenv.env['FIREBASE_PROJECT_ID']!,
      storageBucket: dotenv.env['FIREBASE_STORAGE_BUCKET']!,
      messagingSenderId: dotenv.env['FIREBASE_MESSAGING_SENDER_ID']!,
      appId: dotenv.env['FIREBASE_APP_ID']!,
      measurementId: dotenv.env['FIREBASE_MEASUREMENT_ID']!,
    );
  }

  await Firebase.initializeApp(
    options: firebaseOptions,
  );

  // Enable Firebase Database Offline Persistence
  FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => UserModel(),
      child: MaterialApp(
        title: 'Restaurant App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => SignInScreen(),
          '/kitchen': (context) => KitchenScreen(),
        },
      ),
    );
  }
}
