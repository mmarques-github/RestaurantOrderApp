import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart'; // Keep this for mobile platforms
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'signin_screen.dart';
import 'user_model.dart';
import 'kitchen_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: await FirebaseApi.getFirebaseOptions(),
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
