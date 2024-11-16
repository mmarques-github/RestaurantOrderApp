import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'user_model.dart';
import 'waiter/waiter_home.dart';
import 'chef/chef_home.dart';
import 'customer/customer_home.dart';
import 'preferences.dart'; // Import the Preferences class

class LoginPage extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _login(context),
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }

  void _login(BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );
      User? user = userCredential.user;
      if (user != null) {
        String userId = user.uid;

        // Fetch username from your Firestore users collection
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
        String username = userDoc['username'];
        String userType = userDoc['type'];

        // Save username in preferences
        await Preferences.setUsername(username);

        // Update the user model if you're using a provider
        Provider.of<UserModel>(context, listen: false).setUser(userId, username, userType);

        // Navigate to the appropriate screen
        if (userType == 'waiter') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => WaiterHome()));
        } else if (userType == 'chef') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ChefHome()));
        } else if (userType == 'customer') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CustomerHome()));
        }
      }
    } catch (e) {
      // Handle errors
      print('Login error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    }
  }

  Future<String> _getUserType(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['type'];
  }

  Future<String> _getUsername(String userId) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc['username'];
  }
}
