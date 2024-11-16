import 'package:flutter/material.dart';
import 'order_display.dart';

class ChefHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chef Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => OrderDisplay()));
              },
              child: Text('View Orders'),
            ),
          ],
        ),
      ),
    );
  }
}
