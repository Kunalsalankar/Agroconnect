import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore import
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersFromFirestore(); // Load orders on page load
  }

  // Function to load orders from Firestore
  Future<void> _loadOrdersFromFirestore() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    // Fetch orders from Firestore
    FirebaseFirestore.instance
        .collection('order_id')
        .doc(userId)
        .collection('userOrders')
        .orderBy('timestamp', descending: true)
        .get()
        .then((snapshot) {
      setState(() {
        _orders = snapshot.docs.map((doc) {
          return {
            'paymentId': doc['paymentId'],
            'productId': doc['productId'],
            'productName': doc['productName'],
            'amount': doc['amountPaid'],
            'quantity': doc['quantity'],
            'userName': doc['userName'],
            'userAddress': doc['userAddress'],
            'paymentStatus': doc['paymentStatus'],
          };
        }).toList();
      });
    });
  }

  // Reusable widget to display order options
  Widget _buildOrderOption({
    required String title,
    required String subtitle,
    required void Function() onTap,
  }) {
    return ListTile(
      leading: Icon(Icons.shopping_bag, color: Colors.green),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
      onTap: onTap,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  // Navigate to order details
  void _navigateToOrderDetails(Map<String, dynamic> orderData) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Order Details"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Payment ID: ${orderData['paymentId']}"),
              Text("Product ID: ${orderData['productId']}"),
              Text("Product Name: ${orderData['productName']}"),
              Text("Quantity: ${orderData['quantity']}"),
              Text("Price: ₹${orderData['amount']}"),
              Text("User Name: ${orderData['userName']}"),
              Text("Address: ${orderData['userAddress']}"),
              Text("Payment Status: ${orderData['paymentStatus']}"),
              Text("Order Date: ${DateTime.now().toLocal()}"), // Assuming date is current for demo
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My Orders"),
        backgroundColor: Colors.green,
      ),
      body: _orders.isEmpty
          ? Center(child: Text("No orders found."))
          : ListView(
        padding: EdgeInsets.all(8),
        children: _orders.map((orderData) {
          final orderTitle = "Order for ${orderData['productName']}";
          final orderSubtitle = "Amount: ₹${orderData['amount']}";

          return _buildOrderOption(
            title: orderTitle,
            subtitle: orderSubtitle,
            onTap: () => _navigateToOrderDetails(orderData),
          );
        }).toList(),
      ),
    );
  }
}
