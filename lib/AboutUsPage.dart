import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Implement your About Us Page UI here
    return Scaffold(
      appBar: AppBar(
        title: Text('About Us'),
        backgroundColor: Colors.green[600],
      ),
      body: Center(
        child: Text(
          'About Us Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}