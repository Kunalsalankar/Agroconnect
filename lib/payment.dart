import 'package:flutter/material.dart';

class PaymentPage extends StatelessWidget {
  final Map<String, dynamic> product;

  const PaymentPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Payment'),
        backgroundColor: Colors.green[800],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Complete Payment for:',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Display product info
            Text(
              product['name'] ?? 'Product Name',
              style: TextStyle(fontSize: 22, color: Colors.green[900]),
            ),
            SizedBox(height: 10),
            Text(
              'Total Amount: ₹${product['price'] * product['quantity']}',
              style: TextStyle(fontSize: 18, color: Colors.green[700]),
            ),
            SizedBox(height: 20),

            // Payment Button (Placeholder)
            ElevatedButton.icon(
              onPressed: () {
                _processPayment(context);
              },
              icon: Icon(Icons.payment, size: 30, color: Colors.white),
              label: Text(
                'Pay Now',
                style: TextStyle(fontSize: 20, color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.green[800],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to simulate the payment process
  void _processPayment(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Payment Successful'),
          content: Text('Your payment has been processed successfully.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}