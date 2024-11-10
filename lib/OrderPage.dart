import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderPage extends StatefulWidget {
  final String productId;

  OrderPage({required this.productId});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the fields
  TextEditingController nameController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController instructionsController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController postalCodeController = TextEditingController();
  TextEditingController productNameController = TextEditingController(); // New field
  TextEditingController priceController = TextEditingController(); // New field

  // Function to save order data to Firestore and local storage
  Future<void> saveOrderData() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final orderId = FirebaseFirestore.instance.collection('order id').doc().id; // Generate unique orderId

      // Save to Firestore
      await FirebaseFirestore.instance
          .collection('order_id')
          .doc(userId)
          .collection('userOrders')
          .doc(orderId)
          .set({
        'orderId': orderId,
        'userId': userId,
        'productId': widget.productId,
        'name': nameController.text,
        'contact': contactController.text,
        'email': emailController.text,
        'quantity': quantityController.text,
        'specialInstructions': instructionsController.text,
        'address': addressController.text,
        'city': cityController.text,
        'postalCode': postalCodeController.text,
        'productName': productNameController.text,
        'price': priceController.text,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Save to local storage using SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('orderName', nameController.text);
      prefs.setString('orderContact', contactController.text);
      prefs.setString('orderEmail', emailController.text);
      prefs.setString('orderQuantity', quantityController.text);
      prefs.setString('orderAddress', addressController.text);
      prefs.setString('orderCity', cityController.text);
      prefs.setString('orderPostalCode', postalCodeController.text);
      prefs.setString('productName', productNameController.text);
      prefs.setString('price', priceController.text);

      // Return to previous screen and indicate success
      Navigator.pop(context, true);
    }
  }

  // Helper function to build text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool isEmail = false,
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label + (isRequired ? ' (Required)' : ''),
        border: OutlineInputBorder(),
      ),
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : isNumber
          ? TextInputType.number
          : TextInputType.text,
      maxLines: maxLines,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter your $label';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Delivery Address"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(controller: nameController, label: 'Name', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: contactController, label: 'Contact Number', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: emailController, label: 'Email', isRequired: true, isEmail: true),
              SizedBox(height: 16),
              _buildTextField(controller: addressController, label: 'Delivery Address', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: cityController, label: 'City', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: postalCodeController, label: 'Postal Code', isRequired: true, isNumber: true),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: saveOrderData,
                child: Text('Next'),
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
