import 'package:flutter/material.dart';
import 'signin_screen.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Restaurant App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpScreen()));
            //   },
            //   child: Text('Sign Up'),
            // ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SignInScreen()));
              },
              child: Text('Sign In'),
            ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => WaiterScreen()));
            //   },
            //   child: Text('Waiter Screen'),
            // ),
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(context, MaterialPageRoute(builder: (context) => KitchenScreen()));
            //   },
            //   child: Text('Kitchen Screen'),
            // ),
          ],
        ),
      ),
    );
  }
}
