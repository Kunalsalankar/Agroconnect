import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  // Function to save order data to Firestore and show confirmation dialog
  Future<void> saveOrderData() async {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('ayush').doc().set({
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
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Show confirmation dialog after saving data
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your purchase has been confirmed. Proceed to payment.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Dismiss the dialog
                    Navigator.pushNamed(context, '/paymentPage'); // Navigate to payment page
                  },
                  child: Text(
                    'Proceed to Payment',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
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
              _buildTextField(controller: quantityController, label: 'Quantity', isRequired: true, isNumber: true),
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
