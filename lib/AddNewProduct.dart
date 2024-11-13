import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class AddNewProduct extends StatefulWidget {
  @override
  _AddNewProductState createState() => _AddNewProductState();
}

class _AddNewProductState extends State<AddNewProduct> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController productNameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController farmerNameController = TextEditingController();
  final TextEditingController aadharNumberController = TextEditingController();
  final TextEditingController harvestDateController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _selectedDate;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = pickedFile != null ? File(pickedFile.path) : null;
    });
  }

  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName = 'product_images/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_image!);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    DateTime firstDate = DateTime(2000);
    DateTime lastDate = DateTime(2101);

    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
        harvestDateController.text = _selectedDate!;
      });
    }
  }

  Future<void> _registerProduct() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = await _uploadImage();

      if (_image == null || imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload image. Please try again.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        String userId = FirebaseAuth.instance.currentUser!.uid;

        // Generate a new document ID for consistency in both collections
        DocumentReference productRef = FirebaseFirestore.instance.collection('kunu').doc();
        String productId = productRef.id;

        // Data to be saved in Firestore
        Map<String, dynamic> productData = {
          'productName': productNameController.text.trim(),
          'price': 'Rs ${priceController.text.trim()}',
          'quantity': quantityController.text.trim(),
          'location': locationController.text.trim(),
          'farmerName': farmerNameController.text.trim(),
          'aadharNumber': aadharNumberController.text.trim(),
          'harvestDate': harvestDateController.text.trim(),
          'mobileNumber': mobileNumberController.text.trim(),
          'imageUrl': imageUrl,
          'createdAt': Timestamp.now(),
          'userId': userId,
          'productId': productId,
        };

        // Save to "kunu" collection
        await productRef.set(productData);

        // Save to "order id" collection with the same data and additional fields as required
        await FirebaseFirestore.instance.collection('order_id').doc(productId).set(productData);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Product added successfully!'),
          backgroundColor: Colors.green,
        ));

        // Reset form and UI state
        _formKey.currentState!.reset();
        setState(() {
          _image = null;
          _isLoading = false;
        });
      } catch (e) {
        print('Error adding product: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add product. Please try again.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New Product'),
        backgroundColor: Colors.green[600],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: productNameController,
                decoration: InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the product name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Price (Rs)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'e.g., 10 Quintal',
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
              SizedBox(height: 16),
              TextFormField(
                controller: locationController,
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
              TextFormField(
                controller: farmerNameController,
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
              TextFormField(
                controller: aadharNumberController,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the Mobile number';
                  }
                  if (value.length != 10 && value.length != 10) {
                    return 'Mobile number should be 10 digits';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: harvestDateController,
                decoration: InputDecoration(
                  labelText: 'Harvest Date',
                  hintText: 'DD/MM/YYYY',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the harvest date';
                  }
                  return null;
                },
                onTap: () => _selectDate(context),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  _image == null
                      ? Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: Icon(
                      Icons.image,
                      size: 50,
                      color: Colors.grey[400],
                    ),
                  )
                      : Image.file(
                    _image!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: Icon(Icons.image),
                    label: Text('Pick Image'),
                  ),
                ],
              ),
              SizedBox(height: 32),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _registerProduct,
                child: Text('Upload Product'),
                style: ElevatedButton.styleFrom(
                  padding:
                  EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
