import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PreorderPage extends StatefulWidget {
  final Map<String, dynamic> productData;

  PreorderPage({required this.productData});

  @override
  _PreorderPageState createState() => _PreorderPageState();
}

class _PreorderPageState extends State<PreorderPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();
  DateTime _deliveryDate = DateTime.now();
  String _paymentMethod = 'Cash on Delivery';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preorder ${widget.productData['productName']}'),
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(controller: _nameController, label: 'Name', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: _contactController, label: 'Contact Number', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: _emailController, label: 'Email', isRequired: true, isEmail: true),
              SizedBox(height: 16),
              _buildTextField(controller: _quantityController, label: 'Quantity', isRequired: true, isNumber: true),
              SizedBox(height: 16),
              _buildTextField(controller: _instructionsController, label: 'Special Instructions', maxLines: 3),
              SizedBox(height: 16),
              _buildTextField(controller: _addressController, label: 'Delivery Address', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: _cityController, label: 'City', isRequired: true),
              SizedBox(height: 16),
              _buildTextField(controller: _postalCodeController, label: 'Postal Code', isRequired: true),
              SizedBox(height: 16),

              // Preferred Delivery Date
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _deliveryDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != _deliveryDate) {
                    setState(() {
                      _deliveryDate = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Preferred Delivery Date',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_deliveryDate.toLocal()}'.split(' ')[0],
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Payment Method
              Text(
                'Payment Method',
                style: TextStyle(fontSize: 16),
              ),
              ListTile(
                title: const Text('Cash on Delivery'),
                leading: Radio<String>(
                  value: 'Cash on Delivery',
                  groupValue: _paymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Online Payment'),
                leading: Radio<String>(
                  value: 'Online Payment',
                  groupValue: _paymentMethod,
                  onChanged: (String? value) {
                    setState(() {
                      _paymentMethod = value!;
                    });
                  },
                ),
              ),
              SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final currentUser = FirebaseAuth.instance.currentUser;
                    if (currentUser == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please log in to place a preorder')),
                      );
                      return;
                    }

                    // Prepare preorder data with userId included
                    final preorderData = {
                      'userId': currentUser.uid,
                      'productName': widget.productData['productName'],
                      'farmerId': widget.productData['farmerId'],
                      'name': _nameController.text,
                      'contactNumber': _contactController.text,
                      'email': _emailController.text,
                      'quantity': _quantityController.text,
                      'specialInstructions': _instructionsController.text,
                      'deliveryAddress': _addressController.text,
                      'city': _cityController.text,
                      'postalCode': _postalCodeController.text,
                      'preferredDeliveryDate': _deliveryDate,
                      'paymentMethod': _paymentMethod,
                      'orderDate': DateTime.now(),
                    };

                    try {
                      // Store in 'samyak' collection
                      await FirebaseFirestore.instance
                          .collection('samyak')
                          .add(preorderData);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Preorder placed successfully')),
                      );
                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to place preorder')),
                      );
                    }
                  }
                },
                child: Text('Place Preorder'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  backgroundColor: Colors.green[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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
        labelText: label,
        border: OutlineInputBorder(),
      ),
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return 'Please enter $label';
        }
        if (isEmail && value != null && value.isNotEmpty) {
          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
          if (!emailRegex.hasMatch(value)) {
            return 'Please enter a valid email';
          }
        }
        if (isNumber && value != null && value.isNotEmpty) {
          if (int.tryParse(value) == null) {
            return 'Please enter a valid number';
          }
        }
        return null;
      },
    );
  }
}