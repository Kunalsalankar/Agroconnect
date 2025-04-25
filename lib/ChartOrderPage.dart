import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:googlemerr/razorpay_service.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'razorpay_service.dart';

class CartOrderPage extends StatefulWidget {
  @override
  _CartOrderPageState createState() => _CartOrderPageState();
}

class _CartOrderPageState extends State<CartOrderPage> {
  final _formKey = GlobalKey<FormState>();
  bool isOrderConfirmed = false;
  late RazorpayService _razorpayService;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController contactController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController postalCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _razorpayService = RazorpayService();
  }

  Future<void> _confirmOrder() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final orderId = FirebaseFirestore.instance.collection('order_id').doc().id;

      await FirebaseFirestore.instance
          .collection('order_id')
          .doc(userId)
          .collection('userOrders')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'userId': userId,
        'name': nameController.text,
        'contact': contactController.text,
        'email': emailController.text,
        'address': addressController.text,
        'city': cityController.text,
        'postalCode': postalCodeController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        isOrderConfirmed = true;
      });
    }
  }

  void _confirmPurchase() {
    if (!isOrderConfirmed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please confirm your order first.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Purchase Successful',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                'Your purchase has been confirmed. Proceed to payment.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _proceedToPayment();
                },
                child: Text(
                  'Proceed to Payment',
                  style: TextStyle(fontSize: 18, color: Colors.green),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _proceedToPayment() {
    // Open Razorpay checkout with the necessary details
    _razorpayService.openCheckout(
      context: context,
      amount: '500', // Amount can be dynamically set here
      productName: 'Product Name', // Replace with actual product name
      productId: 'product123', // Replace with actual product ID
      userName: nameController.text,
      userAddress: addressController.text,
    );
  }

  InputDecoration _buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.green),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide(color: Colors.green, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Order Details"),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: nameController,
                decoration: _buildInputDecoration('Name'),
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: contactController,
                decoration: _buildInputDecoration('Contact Number'),
                validator: (value) => value!.isEmpty ? 'Please enter your contact number' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                decoration: _buildInputDecoration('Email'),
                validator: (value) => value!.isEmpty ? 'Please enter your email' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: addressController,
                decoration: _buildInputDecoration('Delivery Address'),
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: cityController,
                decoration: _buildInputDecoration('City'),
                validator: (value) => value!.isEmpty ? 'Please enter your city' : null,
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: postalCodeController,
                decoration: _buildInputDecoration('Postal Code'),
                validator: (value) => value!.isEmpty ? 'Please enter your postal code' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _confirmOrder,
                child: Text('Confirm Order'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              SizedBox(height: 20),
              if (isOrderConfirmed)
                ElevatedButton(
                  onPressed: _confirmPurchase,
                  child: Text('Confirm Purchase'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
