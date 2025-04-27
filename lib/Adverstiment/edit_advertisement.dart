import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditAdvertisement extends StatefulWidget {
  final String docId;
  final Map<String, dynamic> data;

  EditAdvertisement({required this.docId, required this.data});

  @override
  _EditAdvertisementState createState() => _EditAdvertisementState();
}

class _EditAdvertisementState extends State<EditAdvertisement> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _farmerNameController = TextEditingController();
  final TextEditingController _harvestDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _productNameController.text = widget.data['productName'] ?? '';
    _priceController.text = widget.data['price'] ?? '';
    _quantityController.text = widget.data['quantity'] ?? '';
    _locationController.text = widget.data['location'] ?? '';
    _contactNumberController.text = widget.data['contactNumber'] ?? '';
    _farmerNameController.text = widget.data['farmerName'] ?? '';
    _harvestDateController.text = widget.data['harvestDate'] ?? '';
  }

  void _updatePost() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('ayush').doc(widget.docId).update({
          'productName': _productNameController.text.trim(),
          'price': _priceController.text.trim(),
          'quantity': _quantityController.text.trim(),
          'location': _locationController.text.trim(),
          'contactNumber': _contactNumberController.text.trim(),
          'farmerName': _farmerNameController.text.trim(),
          'harvestDate': _harvestDateController.text.trim(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Advertisement updated successfully')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update advertisement')),
        );
      }
    }
  }

  @override
  void dispose() {
    _productNameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _locationController.dispose();
    _contactNumberController.dispose();
    _farmerNameController.dispose();
    _harvestDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Advertisement'),
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Product Name
              TextFormField(
                controller: _productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Price
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Price (Rs)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: _quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the quantity';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the location';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Contact Number
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(
                  labelText: 'Contact Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a contact number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Farmer Name
              TextFormField(
                controller: _farmerNameController,
                decoration: InputDecoration(
                  labelText: 'Farmer Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the farmer name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Harvest Date
              TextFormField(
                controller: _harvestDateController,
                decoration: InputDecoration(
                  labelText: 'Harvest Date',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the harvest date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              // Update Button
              ElevatedButton(
                onPressed: _updatePost,
                child: Text('Update Advertisement'),
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
}