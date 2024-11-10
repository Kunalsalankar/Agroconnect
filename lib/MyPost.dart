import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyPost extends StatefulWidget {
  @override
  _MyPostState createState() => _MyPostState();
}

class _MyPostState extends State<MyPost> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for advertisement fields
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController adDescriptionController = TextEditingController();
  final TextEditingController contactNumberController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController farmerNameController = TextEditingController();
  final TextEditingController harvestDateController = TextEditingController();

  File? _image;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;

  // Pick image from gallery
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );
      setState(() {
        _image = pickedFile != null ? File(pickedFile.path) : null;
      });
    } catch (e) {
      print('Error picking image: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image')),
      );
    }
  }

  // Upload image to Firebase Storage and return download URL
  Future<String?> _uploadImage() async {
    if (_image == null) return null;

    try {
      String fileName =
          'advertisement_images/${DateTime.now().millisecondsSinceEpoch}.png';
      Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      UploadTask uploadTask = storageRef.putFile(_image!);

      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Register advertisement in Firestore
  Future<void> _addAdvertisement() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      String? imageUrl = await _uploadImage();

      if (_image == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please select an image for the advertisement.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to upload image. Please try again.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current user ID
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please log in to post an advertisement.'),
          backgroundColor: Colors.red,
        ));
        setState(() {
          _isLoading = false;
        });
        return;
      }

      try {
        // Add advertisement details to Firestore collection "ayush"
        DocumentReference docRef = await FirebaseFirestore.instance.collection('ayush').add({
          'userId': currentUser.uid, // Add userId here
          'productName': productNameController.text.trim(),
          'description': adDescriptionController.text.trim(),
          'contactNumber': contactNumberController.text.trim(),
          'price': 'Rs ${priceController.text.trim()}',
          'quantity': quantityController.text.trim(),
          'location': locationController.text.trim(),
          'farmerName': farmerNameController.text.trim(),
          'harvestDate': harvestDateController.text.trim(),
          'imageUrl': imageUrl,
          'uploadDate': Timestamp.now(),
        });

        // Set the productId field as the document ID
        await docRef.update({
          'productId': docRef.id, // Add productId as the document ID
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Advertisement added successfully!'),
          backgroundColor: Colors.green,
        ));

        _formKey.currentState!.reset();
        setState(() {
          _image = null;
        });

        // Optionally, navigate to Advertisement page after a short delay
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pop(context);
        });
      } catch (e) {
        print('Error adding advertisement to Firestore: $e');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add advertisement. Please try again.'),
          backgroundColor: Colors.red,
        ));
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all required fields.'),
        backgroundColor: Colors.red,
      ));
    }
  }

  @override
  void dispose() {
    productNameController.dispose();
    adDescriptionController.dispose();
    contactNumberController.dispose();
    priceController.dispose();
    quantityController.dispose();
    locationController.dispose();
    farmerNameController.dispose();
    harvestDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post Advertisement'),
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
                controller: productNameController,
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

              // Advertisement Description
              TextFormField(
                controller: adDescriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Contact Number
              TextFormField(
                controller: contactNumberController,
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

              // Price
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
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Quantity
              TextFormField(
                controller: quantityController,
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

              // Farmer Name
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

              // Harvest Date
              TextFormField(
                controller: harvestDateController,
                decoration: InputDecoration(
                  labelText: 'Harvest Date',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.datetime,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the harvest date';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Image Picker
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pick an Image'),
              ),
              if (_image != null) ...[
                SizedBox(height: 16),
                Image.file(_image!),
              ],

              // Submit Button
              SizedBox(height: 16),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _addAdvertisement,
                child: Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  padding: EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
