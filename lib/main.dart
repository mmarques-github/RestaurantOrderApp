import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_api.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'signin_screen.dart';
import 'user_model.dart';
import 'kitchen_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: await FirebaseApi.getFirebaseOptions(),
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }

  // Proceed with the rest of your code
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);

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
