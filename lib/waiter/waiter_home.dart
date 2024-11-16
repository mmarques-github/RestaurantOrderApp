import 'package:flutter/material.dart';
import 'table_management.dart';

class WaiterHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Waiter Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TableManagement()));
              },
              child: Text('Manage Tables'),
            ),
          ],
        ),
      ),
    );
  }
}
