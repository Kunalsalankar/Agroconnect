import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyOrdersPage extends StatefulWidget {
  @override
  _MyOrdersPageState createState() => _MyOrdersPageState();
}

class _MyOrdersPageState extends State<MyOrdersPage> {
  List<Map<String, String>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrdersFromLocalStorage();
  }

  // Load orders from SharedPreferences
  Future<void> _loadOrdersFromLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    String? paymentId = prefs.getString('paymentId');
    String? productId = prefs.getString('productId');
    String? amount = prefs.getString('amount');
    String? productName = prefs.getString('productName');
    String? price = prefs.getString('price');

    if (paymentId != null && productId != null && amount != null && productName != null && price != null) {
      setState(() {
        _orders.add({
          'paymentId': paymentId,
          'productId': productId,
          'amount': amount,
          'productName': productName,
          'price': price,
        });
      });
    }
  }

  // Order item UI
  Widget _buildOrderOption({
    required String title,
    required String subtitle,
    required void Function() onTap,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(Icons.shopping_bag, color: Colors.green),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: onTap,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }

  // Show order details in a dialog
  void _navigateToOrderDetails(Map<String, String> orderData) {
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
              Text("Price: ₹${orderData['price']}"),
              Text("Amount: ₹${orderData['amount']}"),
              Text("Order Date: ${DateTime.now().toLocal()}"),
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

  // Preorder section with real-time updates
  Widget _buildPreorderSection() {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      return Center(child: Text('Please log in to see your preorders.'));
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('samyak')
            .where('userId', isEqualTo: currentUser.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No preorders found for this user.'));
          }

          final preorders = snapshot.data!.docs;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Advertisement Preorder',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: preorders.length,
                itemBuilder: (context, index) {
                  final preorder = preorders[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        preorder['productName'] ?? 'No Product Name',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${preorder['name'] ?? 'N/A'}'),
                          Text('Quantity: ${preorder['quantity'] ?? 'N/A'}'),
                          Text(
                            'Delivery Date: ${preorder['preferredDeliveryDate'] != null ? preorder['preferredDeliveryDate'].toDate().toString() : 'N/A'}',
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final shouldDelete = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Confirm Deletion'),
                              content: Text('Are you sure you want to delete this preorder?'),
                              actions: [
                                TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(false),
                                ),
                                TextButton(
                                  child: Text('Delete'),
                                  onPressed: () => Navigator.of(context).pop(true),
                                ),
                              ],
                            ),
                          );

                          if (shouldDelete == true) {
                            try {
                              // Delete from Firestore
                              await FirebaseFirestore.instance
                                  .collection('samyak')
                                  .doc(preorder.id)
                                  .delete();

                              // Show success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Preorder deleted successfully')),
                              );
                            } catch (e) {
                              // Show error message if deletion fails
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete preorder: $e')),
                              );
                            }
                          }
                        },
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_orders.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              ),
            _buildPreorderSection(),
          ],
        ),
      ),
    );
  }
}
