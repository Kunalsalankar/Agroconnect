import 'package:flutter/material.dart';

class AuctionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Auction Services'),
      ),
      body: Center(
        child: Text(
          'Details about Auction Services',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
