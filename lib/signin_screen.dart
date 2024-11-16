import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'waiter_screen.dart';
import 'kitchen_screen.dart';
import 'preferences.dart'; // Import Preferences

class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                String username = usernameController.text.trim();
                String password = passwordController.text.trim();

                if (username.isNotEmpty && password.isNotEmpty) {
                  // Sign in and get user info
                  bool result = await _authService.signIn(username, password);
                  if (result) {
                    print('Sign in successful');

                    // Save the username to preferences
                    await Preferences.setUsername(username);

                    // Get user info
                    var userInfo = await _authService.getUserInfo(username);
                    print("User info: $userInfo");

                    // Navigate to the appropriate screen based on user type
                    if (userInfo?['type'] == 'waiter') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => WaiterScreen()),
                      );
                    } else if (userInfo?['type'] == 'chef') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => KitchenScreen()),
                      );
                    } else {
                      print('Invalid user type');
                      Navigator.pop(context);
                    }
                  } else {
                    print('Sign in failed');
                    // Show error message
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Sign In Failed'),
                          content: Text('Invalid username or password'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  }
                }
              },
              child: Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
